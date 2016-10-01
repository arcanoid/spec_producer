require "spec_producer/version"
require "spec_producer/missing_files_module"
require "spec_producer/spec_production_module"

module SpecProducer
  def self.produce_specs_for_all_types
    set_up_necessities
    SpecProductionModule.produce_specs_for_models
    SpecProductionModule.produce_specs_for_routes
    SpecProductionModule.produce_specs_for_views
    SpecProductionModule.produce_specs_for_controllers
    SpecProductionModule.produce_specs_for_helpers
  end

  def self.produce_specs_for_models
    SpecProductionModule.produce_specs_for_models
  end

  def self.produce_specs_for_routes
    SpecProductionModule.produce_specs_for_routes
  end

  def self.produce_specs_for_views
    SpecProductionModule.produce_specs_for_views
  end

  def self.produce_specs_for_controllers
    SpecProductionModule.produce_specs_for_controllers
  end

  def self.produce_specs_for_helpers
    SpecProductionModule.produce_specs_for_helpers
  end

  def self.set_up_necessities
    gemfiles = Dir.glob(Rails.root.join('Gemfile'))

    if gemfiles.size > 0
      contents = File.read(gemfiles.first)
      gems = contents.scan(/gem \'(?<gem>\S*)\'/).flatten.uniq
      missing_gems = []

      missing_gems << 'rspec-rails' unless (gems.include? 'rspec-rails')
      missing_gems << 'factory_girl_rails' unless (gems.include? 'factory_girl_rails')
      missing_gems << 'shoulda-matchers' unless (gems.include? 'shoulda-matchers')
      missing_gems << 'capybara' unless (gems.include? 'capybara')

      if missing_gems.size > 0
        contents << "\ngroup :test do\n"

        missing_gems.each do |gem|
          contents << "  gem '#{gem}'\n"
        end

        contents << "end"
      end

      f = File.open(gemfiles.first, 'wb+')
      f.write(contents)
      f.close
    else
      puts "We couldn't find a Gemfile and setting up halted!"
    end
  end

  def self.produce_factories
    Dir.glob(Rails.root.join('app/models/*.rb')).each do |x|
      require x
    end

    ActiveRecord::Base.descendants.each do |descendant|
      final_text = "FactoryGirl.define do\n"
      final_text << "  factory :#{descendant.name.underscore}, :class => #{descendant.name} do\n"

      descendant.columns.each do |column|
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

      final_text << "  end\n"
      final_text << "end"

      if File.exists?(Rails.root.join("spec/factories/#{descendant.name.underscore}.rb"))
        puts '#'*100
        puts "Please, check whether the following lines are included in: spec/factories/" + descendant.name.underscore + ".rb\n"
        puts '#'*100
        puts "\n"
        puts final_text
      else
        unless Dir.exists? Rails.root.join("spec")
          puts "Generating spec directory"
          Dir.mkdir(Rails.root.join("spec"))
        end

        unless Dir.exists? Rails.root.join("spec/factories")
          puts "Generating spec/factories directory"
          Dir.mkdir(Rails.root.join("spec/factories"))
        end

        path = "spec/factories/#{descendant.name.underscore}.rb"
        puts "Producing factory file for: #{path}"
        f = File.open("#{Rails.root.join(path)}", 'wb+')
        f.write(final_text)
        f.close
      end
    end

    nil
  rescue NameError
    puts "ActiveRecord is not set for this project. Can't produce factories for this project."
  end

  def self.print_all_missing_spec_files
    MissingFiles.print_missing_model_specs
    MissingFiles.print_missing_controller_specs
    MissingFiles.print_missing_helper_specs
    MissingFiles.print_missing_view_specs
    MissingFiles.print_missing_mailer_specs
    MissingFiles.print_missing_job_specs
  end

  def self.print_missing_model_specs
    MissingFiles.print_missing_model_specs
  end

  def self.print_missing_controller_specs
    MissingFiles.print_missing_controller_specs
  end

  def self.print_missing_helper_specs
    MissingFiles.print_missing_helper_specs
  end

  def self.print_missing_view_specs
    MissingFiles.print_missing_view_specs
  end

  def self.print_missing_mailer_specs
    MissingFiles.print_missing_mailer_specs
  end

  def self.print_missing_job_specs
    MissingFiles.print_missing_job_specs
  end
end