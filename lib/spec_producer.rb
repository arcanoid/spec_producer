require "spec_producer/version"

module SpecProducer
  def self.produce_specs_for_all_types
    produce_specs_for_models
    produce_specs_for_routes
    produce_specs_for_views
    produce_specs_for_controllers
    produce_specs_for_helpers
  end

  def self.produce_specs_for_models
    Dir.glob(Rails.root.join('app/models/*.rb')).each do |x|
      require x
    end

    ActiveRecord::Base.descendants.each do |descendant|
      final_text = "require 'rails_helper'\n\n"
      final_text << "describe #{descendant.name} do\n"

      descendant.attribute_names.each do |attribute|
        final_text << "\tit { should respond_to :#{attribute}, :#{attribute}= }\n"
      end

      descendant.readonly_attributes.each do |attribute|
        final_text << "\tit { should have_readonly_attribute :#{attribute} }\n"
      end

      if descendant.validators.reject { |validator| validator.kind == :associated }.present?
        final_text << "\n\t# Validators\n"
      end

      descendant.validators.each do |validator|
        if validator.kind == :presence
          validator.attributes.each do |attribute|
            final_text << "\tit { should validate_presence_of :#{attribute} }\n"
          end
        elsif validator.kind == :uniqueness
          validator.attributes.each do |attribute|
            final_text << "\tit { should validate_uniqueness_of :#{attribute} }\n"
          end
        elsif validator.kind == :numericality
          validator.attributes.each do |attribute|
            final_text << "\tit { should validate_numericality_of :#{attribute} }\n"
          end
        elsif validator.kind == :acceptance
          validator.attributes.each do |attribute|
            final_text << "\tit { should validate_acceptance_of :#{attribute} }\n"
          end
        elsif validator.kind == :confirmation
          validator.attributes.each do |attribute|
            final_text << "\tit { should validate_confirmation_of :#{attribute} }\n"
          end
        elsif validator.kind == :length
          validator.attributes.each do |attribute|
            final_text << "\tit { should validate_length_of :#{attribute} }\n"
          end
        elsif validator.kind == :absence
          validator.attributes.each do |attribute|
            final_text << "\tit { should validate_absence_of :#{attribute} }\n"
          end
        end
      end

      if descendant.column_names.present?
        final_text << "\n\t# Columns\n"
      end

      descendant.column_names.each do |column_name|
        final_text << "\tit { should have_db_column :#{column_name} }\n"
      end

      if descendant.reflections.keys.present?
        final_text << "\n\t# Associations\n"
      end

      descendant.reflections.keys.each do |key|
        final_text << case descendant.reflections[key].macro
          when :belongs_to then "\tit { should belong_to :#{key} }\n"
          when :has_one then "\tit { should have_one :#{key} }\n"
          when :has_many then "\tit { should have_many :#{key} }\n"
        end
      end

      final_text << "end"

      if File.exists?(Rails.root.join("spec/models/#{descendant.name.downcase}_spec.rb"))
        puts '#'*100
        puts "Please, check whether the following lines are included in: " + descendant.name.downcase + "_spec.rb\n"
        puts '#'*100
        puts "\n"
        puts final_text
      else
        unless Dir.exists? Rails.root.join("spec/models")
          puts "Generating spec/models directory"
          Dir.mkdir(Rails.root.join("spec/models"))
        end

        path = "spec/models/#{descendant.name.downcase}_spec.rb"
        puts "Creating spec file for #{path}"
        f = File.open("#{Rails.root.join(path)}", 'wb+')
        f.write(final_text)
        f.close
      end
    end

    nil
  end

  def self.produce_specs_for_routes
    routes = Rails.application.routes.routes.map do |route|
      path = route.path.spec.to_s.gsub(/\(\.:format\)/, "")
      verb = %W{ GET POST PUT PATCH DELETE }.grep(route.verb).first.downcase.to_sym
      controller = route.defaults[:controller]
      action = route.defaults[:action]

      if controller.present? && !/^rails/.match(controller)
        { :path => path, :verb => verb, :controller => controller, :action => action }
      end
    end.compact

    routes.group_by { |route| route[:controller] }.each do |route_group|
      final_text = "require 'rails_helper'\n\n"
      final_text << "describe '#{route_group[0]} routes' do\n"

      route_group[1].each do |route|
        final_text << "\tit \"#{route[:verb].upcase} #{route[:path]} should route to '#{route[:controller]}##{route[:action]}'\" do\n"

        final_text << "\t\t{ :#{route[:verb]} => '#{route[:path].gsub(/:[a-zA-Z_]+/){ |param| param.gsub(':','').upcase }}'}.\n"
        final_text << "\t\t\tshould route_to(:controller => '#{route[:controller]}',\n"

        /:[a-zA-Z_]+/.match(route[:path]).to_a.each do |parameter|
          final_text << "\t\t\t\t\t\t\t#{parameter} => '#{parameter.gsub(':','').upcase}',\n"
        end

        final_text << "\t\t\t\t\t:action => '#{route[:action]}')\n"
        final_text << "\tend\n\n"
      end

      final_text << 'end'

      if File.exists?(Rails.root.join("spec/routing/#{route_group[0]}_routing_spec.rb"))
        puts '#'*100
        puts "Please, check whether the following lines are included in: spec/routing/#{route_group[0]}_routing_spec.rb\n"
        puts '#'*100
        puts "\n"
        puts final_text
      else
        unless Dir.exists? Rails.root.join("spec/routing")
          puts "Generating spec/routing directory"
          Dir.mkdir(Rails.root.join("spec/routing"))
        end

        path = "spec/routing/#{route_group[0]}_routing_spec.rb"
        puts "Creating spec file for #{route_group[0]}"
        f = File.open("#{Rails.root.join(path)}", 'wb+')
        f.write(final_text)
        f.close
      end
    end

    nil
  end

  def self.produce_specs_for_views
    files_list = Dir["app/views/**/*.erb"]

    files_list.each do |file|
      full_path = 'spec'
      File.dirname(file.gsub('app/', 'spec/')).split('/').reject { |path| path == 'spec' }.each do |path|
        unless /.*\.erb/.match path
          full_path << "/#{path}"

          unless Dir.exists? full_path
            Dir.mkdir(Rails.root.join(full_path))
          end
        end
      end

      file_name = "#{file.gsub('app/', 'spec/')}_spec.rb"
      final_text = "require 'rails_helper'\n\n"
      final_text << "describe '#{file.gsub('app/views/', '')}' do\n"
      final_text << "\tbefore do\n"
      final_text << "\t\trender\n"
      final_text << "\tend\n\n"
      final_text << "\tpending 'view content test'\n"
      final_text << "end\n"

      unless FileTest.exists?(file_name)
        f = File.open(file_name, 'wb+')
        f.write(final_text)
        f.close
      end
    end

    nil
  end

  def self.produce_specs_for_helpers
    files_list = Dir["app/helpers/**/*.rb"]

    files_list.each do |file|
      full_path = 'spec'
      File.dirname(file.gsub('app/', 'spec/')).split('/').reject { |path| path == 'spec' }.each do |path|
        unless /.*\.rb/.match path
          full_path << "/#{path}"

          unless Dir.exists? full_path
            Dir.mkdir(Rails.root.join(full_path))
          end
        end
      end

      file_name = "#{file.gsub('app/', 'spec/').gsub('.rb', '')}_spec.rb"
      final_text = "require 'rails_helper'\n\n"
      final_text << "describe #{File.basename(file, ".rb").camelcase} do\n"
      final_text << "\tpending 'view helper tests'\n"
      final_text << "end"

      unless FileTest.exists?(file_name)
        f = File.open(file_name, 'wb+')
        f.write(final_text)
        f.close
      end
    end

    nil
  end

  def self.produce_specs_for_controllers
    Dir.glob(Rails.root.join('app/controllers/*.rb')).each do |x|
      require x
    end

    controllers = ApplicationController.descendants
    controllers << ApplicationController

    controllers.each do |descendant|
      path_name = 'app/controllers/' + descendant.name.split('::').map { |name| name.underscore }.join('/')

      full_path = 'spec'
      File.dirname(path_name.gsub('app/', 'spec/')).split('/').reject { |path| path == 'spec' }.each do |path|
        unless /.*\.rb/.match path
          full_path << "/#{path}"

          unless Dir.exists? full_path
            Dir.mkdir(Rails.root.join(full_path))
          end
        end
      end

      file_name = "#{path_name.gsub('app/', 'spec/')}_spec.rb"
      final_text = "require 'rails_helper'\n\n"
      final_text << "describe #{descendant.name} do\n"

      descendant.action_methods.each do |method|
        final_text << "\tpending '##{method}'\n"
      end

      unless descendant.action_methods.size > 0
        final_text << "\tpending 'tests'\n"
      end

      final_text << "end\n"

      unless FileTest.exists?(file_name)
        f = File.open(file_name, 'wb+')
        f.write(final_text)
        f.close
      end
    end

    nil
  end

  def self.print_all_missing_spec_files
    print_missing_model_specs
    print_missing_controller_specs
    print_missing_helper_specs
    print_missing_view_specs
  end

  def self.print_missing_model_specs
    files_list = Dir["app/models/**/*.rb"]

    puts "\n" << "## Searching for missing model specs..."
    files_list.each do |file|
      unless FileTest.exists?(file.gsub('app/', 'spec/').gsub('.rb', '_spec.rb'))
        puts "Missing model spec file for: #{file}"
      end
    end

    nil
  end

  def self.print_missing_controller_specs
    files_list = Dir["app/controllers/**/*.rb"]

    puts "\n" << "## Searching for missing controller specs..."
    files_list.each do |file|
      unless FileTest.exists?(file.gsub('app/', 'spec/').gsub('.rb', '_spec.rb'))
        puts "Missing controller spec file for: #{file}"
      end
    end

    nil
  end

  def self.print_missing_helper_specs
    files_list = Dir["app/helpers/**/*.rb"]

    puts "\n" << "## Searching for missing helper specs..."
    files_list.each do |file|
      unless FileTest.exists?(file.gsub('app/', 'spec/').gsub('.rb', '_spec.rb'))
        puts "Missing helper spec file for: #{file}"
      end
    end

    nil
  end

  def self.print_missing_view_specs
    files_list = Dir["app/views/**/*.erb"]

    puts "\n" << "## Searching for missing view specs..."
    files_list.each do |file|
      unless FileTest.exists?("#{file.gsub('app/', 'spec/')}_spec.rb")
        puts "Missing spec file for: #{file}"
      end
    end

    nil
  end
end
