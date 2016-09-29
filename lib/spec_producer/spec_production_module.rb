module SpecProductionModule
  def self.produce_specs_for_models
    Dir.glob(Rails.root.join('app/models/*.rb')).each do |x|
      require x
    end

    ActiveRecord::Base.descendants.each do |descendant|
      final_text = "require '#{require_helper_string}'\n\n"
      final_text << "describe #{descendant.name}, :type => :model do\n"

      descendant.attribute_names.each do |attribute|
        final_text << "  it { should respond_to :#{attribute}, :#{attribute}= }\n"
      end

      descendant.readonly_attributes.each do |attribute|
        final_text << "  it { should have_readonly_attribute :#{attribute} }\n"
      end

      if descendant.validators.reject { |validator| validator.kind == :associated }.present?
        final_text << "\n  # Validators\n"
      end

      descendant.validators.each do |validator|
        if validator.kind == :presence
          validator.attributes.each do |attribute|
            final_text << "  it { should validate_presence_of :#{attribute} }\n"
          end
        elsif validator.kind == :uniqueness
          validator.attributes.each do |attribute|
            final_text << "  it { should validate_uniqueness_of :#{attribute} }\n"
          end
        elsif validator.kind == :numericality
          validator.attributes.each do |attribute|
            final_text << "  it { should validate_numericality_of :#{attribute} }\n"
          end
        elsif validator.kind == :acceptance
          validator.attributes.each do |attribute|
            final_text << "  it { should validate_acceptance_of :#{attribute} }\n"
          end
        elsif validator.kind == :confirmation
          validator.attributes.each do |attribute|
            final_text << "  it { should validate_confirmation_of :#{attribute} }\n"
          end
        elsif validator.kind == :length
          validator.attributes.each do |attribute|
            final_text << "  it { should validate_length_of :#{attribute} }\n"
          end
        elsif validator.kind == :absence
          validator.attributes.each do |attribute|
            final_text << "  it { should validate_absence_of :#{attribute} }\n"
          end
        end
      end

      if descendant.column_names.present?
        final_text << "\n  # Columns\n"
      end

      descendant.column_names.each do |column_name|
        final_text << "  it { should have_db_column :#{column_name} }\n"
      end

      if descendant.reflections.keys.present?
        final_text << "\n  # Associations\n"
      end

      descendant.reflections.each_pair do |key, reflection|
        final_text << case reflection.macro
                        when :belongs_to then "  it { should belong_to(:#{key})#{produce_association_options(reflection)} }\n"
                        when :has_one then "  it { should have_one(:#{key})#{produce_association_options(reflection)} }\n"
                        when :has_many then "  it { should have_many(:#{key})#{produce_association_options(reflection)} }\n"
                        when :has_and_belongs_to_many then "  it { should have_and_belong_to_many(:#{key})#{produce_association_options(reflection)} }\n"
                      end
      end

      final_text << "end"

      if File.exists?(Rails.root.join("spec/models/#{descendant.name.underscore}_spec.rb"))
        puts '#'*100
        puts "Please, check whether the following lines are included in: " + descendant.name.underscore + "_spec.rb\n"
        puts '#'*100
        puts "\n"
        puts final_text
      else
        unless Dir.exists? Rails.root.join("spec")
          puts "Generating spec directory"
          Dir.mkdir(Rails.root.join("spec"))
        end

        unless Dir.exists? Rails.root.join("spec/models")
          puts "Generating spec/models directory"
          Dir.mkdir(Rails.root.join("spec/models"))
        end

        path = "spec/models/#{descendant.name.underscore}_spec.rb"
        puts "Producing model spec file for: #{path}"
        f = File.open("#{Rails.root.join(path)}", 'wb+')
        f.write(final_text)
        f.close
      end
    end

    nil
  rescue NameError
    puts "ActiveRecord is not set for this project. Skipping model specs production."
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
      final_text = "require '#{require_helper_string}'\n\n"
      final_text << "describe '#{route_group[0]} routes', :type => :routing do\n"

      route_group[1].each_with_index do |route, index|
        final_text << "\n" unless index == 0
        final_text << "  it \"#{route[:verb].upcase} #{route[:path].gsub(/\(.*?\)/, '')} should route to '#{route[:controller]}##{route[:action]}'\" do\n"

        final_text << "    expect(:#{route[:verb]} => '#{route[:path].gsub(/\(.*?\)/, '').gsub(/:[a-zA-Z_]+/){ |param| param.gsub(':','').upcase }}').\n"
        final_text << "        to route_to(:controller => '#{route[:controller]}',\n"
        final_text << "                    :action => '#{route[:action]}'"

        route[:path].gsub(/\(.*?\)/, '').scan(/:[a-zA-Z_]+/).flatten.each do |parameter|
          final_text << ",\n                    #{parameter} => '#{parameter.gsub(':','').upcase}'"
        end

        final_text << ")\n  end\n"
      end

      final_text << "end\n"

      if File.exists?(Rails.root.join("spec/routing/#{route_group[0]}_routing_spec.rb"))
        if File.open(Rails.root.join("spec/routing/#{route_group[0]}_routing_spec.rb")).read == final_text
          # nothing to do here, pre-existing content is the same :)
        else
          puts '#'*100
          puts "Please, check whether the following lines are included in: spec/routing/#{route_group[0]}_routing_spec.rb\n"
          puts '#'*100
          puts "\n"
          puts final_text
        end
      else
        unless Dir.exists? Rails.root.join("spec")
          puts "Generating spec directory"
          Dir.mkdir(Rails.root.join("spec"))
        end

        unless Dir.exists? Rails.root.join("spec/routing")
          puts "Generating spec/routing directory"
          Dir.mkdir(Rails.root.join("spec/routing"))
        end

        # Check whether the route is not in top level namespace but deeper
        full_path = 'spec/routing'
        paths = route_group[0].split('/')

        # And if it is deeper in the tree make sure to check if the related namespaces exist or create them
        if paths.size > 1
          paths.each do |path|
            unless path == paths.last
              full_path << "/#{path}"

              unless Dir.exists? full_path
                Dir.mkdir(Rails.root.join(full_path))
              end
            end
          end
        end

        path = "spec/routing/#{route_group[0]}_routing_spec.rb"
        puts "Producing routing spec file for: #{route_group[0]}"
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
      final_text = "require '#{require_helper_string}'\n\n"
      final_text << "describe '#{file.gsub('app/views/', '')}', :type => :view do\n"
      final_text << "  let(:page) { Capybara::Node::Simple.new(rendered) }\n"
      final_text << "  subject { page }\n\n"
      final_text << "  before do\n"
      final_text << "    render\n"
      final_text << "  end\n\n"
      final_text << "  pending 'view content test'\n"
      final_text << "end\n"

      unless Dir.exists? Rails.root.join("spec")
        puts "Generating spec directory"
        Dir.mkdir(Rails.root.join("spec"))
      end

      unless FileTest.exists?(file_name)
        puts "Producing view spec file for: #{file_name}"
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
      final_text = "require '#{require_helper_string}'\n\n"
      final_text << "describe #{File.basename(file, ".rb").camelcase}, :type => :helper do\n"
      final_text << "  pending 'view helper tests'\n"
      final_text << "end"

      unless Dir.exists? Rails.root.join("spec")
        puts "Generating spec directory"
        Dir.mkdir(Rails.root.join("spec"))
      end

      unless FileTest.exists?(file_name)
        puts "Producing helper spec file for: #{file_name}"
        f = File.open(file_name, 'wb+')
        f.write(final_text)
        f.close
      end
    end

    nil
  end

  def self.produce_specs_for_controllers
    Dir.glob(Rails.root.join('app/controllers/**/*.rb')).each do |x|
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
      final_text = "require '#{require_helper_string}'\n\n"
      final_text << "describe #{descendant.name}, :type => :controller do\n"

      descendant.action_methods.each do |method|
        final_text << "  pending '##{method}'\n"
      end

      unless descendant.action_methods.size > 0
        final_text << "  pending 'tests'\n"
      end

      final_text << "end\n"

      unless Dir.exists? Rails.root.join("spec")
        puts "Generating spec directory"
        Dir.mkdir(Rails.root.join("spec"))
      end

      unless FileTest.exists?(file_name)
        puts "Producing controller spec file for: #{file_name}"
        f = File.open(file_name, 'wb+')
        f.write(final_text)
        f.close
      end
    end

    nil
  end
end
