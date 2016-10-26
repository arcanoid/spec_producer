module SpecProducer::FactoriesProductionModule
  def self.produce_factories
    Dir.glob(Rails.root.join('app/models/*.rb')).each do |x|
      require x
    end

    not_valid_descendants = [ ActiveRecord::SchemaMigration ]

    if Object.const_defined?('Delayed')
      not_valid_descendants << Delayed::Backend::ActiveRecord::Job
    end

    ActiveRecord::Base.descendants.reject { |descendant| not_valid_descendants.include? descendant }.each do |descendant|
      final_text = "FactoryGirl.define do\n"
      final_text << "  factory :#{descendant.name.underscore}, :class => #{descendant.name} do\n"

      descendant.columns.reject { |column| ['id', 'created_at', 'updated_at'].include? column.name }.each do |column|
        value = case column.type
                  when :string then "'#{descendant.name.underscore.upcase}_#{column.name.underscore.upcase}'"
                  when :text then "'#{descendant.name.underscore.upcase}_#{column.name.underscore.upcase}'"
                  when :integer then "#{rand(1...10)}"
                  when :decimal then "#{rand(1.0...100.0)}"
                  when :float then "#{rand(1.0...100.0)}"
                  when :datetime then "'#{DateTime.now + 365}'"
                  when :time then "'#{Time.now + 365*24*60*60}'"
                  when :date then "'#{Date.today + 365}'"
                  when :boolean then "#{rand(2) == 1 ? true : false}"
                  when :binary then "#{5.times.collect { rand(0..1).to_s }.join('')}"
                end

        final_text << "    #{column.name} #{value}\n"
      end
             
      descendant.reflections.each_pair do |key, reflection|
        if reflection.macro == :has_one
          final_text << "    association :#{key.to_s}\n"  
        end
      end

      final_text << "  end\n"
      final_text << "end"

      if File.exists?(Rails.root.join("spec/factories/#{descendant.name.underscore}.rb"))
        puts ('#'*100).colorize(:light_blue)
        puts ("Please, check whether the following lines are included in: spec/factories/" + descendant.name.underscore + ".rb").colorize(:light_blue)
        puts ('#'*100).colorize(:light_blue)
        puts final_text
        puts "\n\n"
      else
        unless Dir.exists? Rails.root.join("spec")
          puts "Generating spec directory".colorize(:yellow)
          Dir.mkdir(Rails.root.join("spec"))
        end

        unless Dir.exists? Rails.root.join("spec/factories")
          puts "Generating spec/factories directory".colorize(:yellow)
          Dir.mkdir(Rails.root.join("spec/factories"))
        end

        path = "spec/factories/#{descendant.name.underscore}.rb"
        puts "Producing factory file for: #{path}".colorize(:green)
        f = File.open("#{Rails.root.join(path)}", 'wb+')
        f.write(final_text)
        f.close
      end
    end

    nil
  rescue NameError => e
    puts "NameError '#{e}' was raised. Can't produce factories for this project.".colorize(:red)
  rescue Exception => e
    puts "Exception '#{e}' was raised. Skipping factories production.".colorize(:red)
  end
end
