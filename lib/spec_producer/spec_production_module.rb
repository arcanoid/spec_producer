require 'colorize'

module SpecProducer::SpecProductionModule
  def self.produce_specs_for_models
    Dir.glob(Rails.root.join('app/models/*.rb')).each do |x|
      require x
    end
    
    not_valid_descendants = [ ActiveRecord::SchemaMigration ]

    if Object.const_defined?('Delayed')
      not_valid_descendants << Delayed::Backend::ActiveRecord::Job
    end

    ActiveRecord::Base.descendants.reject { |descendant| not_valid_descendants.include? descendant }.each do |descendant|
      final_text = "require '#{require_helper_string}'\n\n"
      final_text << "describe #{descendant.name}, :type => :model do\n"

      descendant.attribute_names.each do |attribute|
        final_text << "  it { is_expected.to respond_to :#{attribute}, :#{attribute}= }\n"
      end

      descendant.readonly_attributes.each do |attribute|
        final_text << "  it { is_expected.to have_readonly_attribute :#{attribute} }\n"
      end

      if descendant.validators.reject { |validator| validator.kind == :associated }.present?
        final_text << "\n  # Validators\n"
      end

      descendant.validators.each do |validator|
        if validator.kind == :presence
          validator.attributes.each do |attribute|
            final_text << "  it { is_expected.to validate_presence_of :#{attribute} }\n"
          end
        elsif validator.kind == :uniqueness
          validator.attributes.each do |attribute|
            final_text << "  it { is_expected.to validate_uniqueness_of :#{attribute} }\n"
          end
        elsif validator.kind == :numericality
          validator.attributes.each do |attribute|
            final_text << "  it { is_expected.to validate_numericality_of :#{attribute} }\n"
          end
        elsif validator.kind == :acceptance
          validator.attributes.each do |attribute|
            final_text << "  it { is_expected.to validate_acceptance_of :#{attribute} }\n"
          end
        elsif validator.kind == :confirmation
          validator.attributes.each do |attribute|
            final_text << "  it { is_expected.to validate_confirmation_of :#{attribute} }\n"
          end
        elsif validator.kind == :length
          validator.attributes.each do |attribute|
            final_text << "  it { is_expected.to validate_length_of :#{attribute} }\n"
          end
        elsif validator.kind == :absence
          validator.attributes.each do |attribute|
            final_text << "  it { is_expected.to validate_absence_of :#{attribute} }\n"
          end
        end
      end

      if descendant.column_names.present?
        final_text << "\n  # Columns\n"
      end

      descendant.column_names.each do |column_name|
        final_text << "  it { is_expected.to have_db_column :#{column_name} }\n"
      end

      final_text << "  describe 'valid?'\n"
      final_text << "    subject { FactoryGirl.build(:#{descendant.name.underscore}).valid? }\n\n"
      final_text << "    it { is_expected.to eq(true) }\n"
      final_text << "  end\n\n"

      if descendant.reflections.keys.present?
        final_text << "\n  # Associations\n"
      end

      descendant.reflections.each_pair do |key, reflection|
        final_text << case reflection.macro
                        when :belongs_to then "  it { is_expected.to belong_to(:#{key})#{produce_association_options(reflection)} }\n"
                        when :has_one then "  it { is_expected.to have_one(:#{key})#{produce_association_options(reflection)} }\n"
                        when :has_many then "  it { is_expected.to have_many(:#{key})#{produce_association_options(reflection)} }\n"
                        when :has_and_belongs_to_many then "  it { is_expected.to have_and_belong_to_many(:#{key})#{produce_association_options(reflection)} }\n"
                      end
      end

      final_text << "end"

      if File.exists?(Rails.root.join("spec/models/#{descendant.name.underscore}_spec.rb"))
        if File.open(Rails.root.join("spec/models/#{descendant.name.underscore}_spec.rb")).read == final_text
          # nothing to do here, pre-existing content is the same :)
        else
          puts ('#'*100).colorize(:light_blue)
          puts ("Please, check whether the following lines are included in: " + descendant.name.underscore + "_spec.rb").colorize(:light_blue)
          puts ('#'*100).colorize(:light_blue)
          puts final_text
          puts "\n\n"
        end
      else
        check_if_spec_folder_exists

        unless Dir.exists? Rails.root.join("spec/models")
          puts "Generating spec/models directory".colorize(:yellow)
          Dir.mkdir(Rails.root.join("spec/models"))
        end

        path = "spec/models/#{descendant.name.underscore}_spec.rb"
        puts "Producing model spec file for: #{path}".colorize(:green)
        f = File.open("#{Rails.root.join(path)}", 'wb+')
        f.write(final_text)
        f.close
      end
    end

    nil
  rescue NameError
    puts "ActiveRecord is not set for this project. Skipping model specs production.".colorize(:red)
  rescue Exception => e
    puts "Exception '#{e}' was raised. Skipping model specs production.".colorize(:red)
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
          puts ('#'*100).colorize(:light_blue)
          puts "Please, check whether the following lines are included in: spec/routing/#{route_group[0]}_routing_spec.rb".colorize(:light_blue)
          puts ('#'*100).colorize(:light_blue)
          puts final_text
          puts "\n\n"
        end
      else
        check_if_spec_folder_exists

        unless Dir.exists? Rails.root.join("spec/routing")
          puts "Generating spec/routing directory".colorize(:yellow)
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
        puts "Producing routing spec file for: #{route_group[0]}".colorize(:green)
        f = File.open("#{Rails.root.join(path)}", 'wb+')
        f.write(final_text)
        f.close
      end
    end

    nil
  rescue Exception => e
    puts "Exception '#{e}' was raised. Skipping route specs production.".colorize(:red)
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

      file_content = File.read(file)
      fields_in_file = file_content.scan(/(check_box_tag|text_field_tag|text_area_tag|select_tag|email_field_tag|color_field_tag|date_field_tag|datetime_field_tag|datetime_local_field_tag|hidden_field_tag|password_field_tag|phone_field_tag|radio_button_tag) \:(?<field>[a-zA-Z_]*)/).flatten.uniq
      objects_in_file = file_content.scan(/@(?<field>[a-zA-Z_]*)/).flatten.uniq
      templates_in_file = file_content.scan(/render ('|")(?<template>\S*)('|")/).flatten.uniq
      partials_in_file = file_content.scan(/render :partial => ('|")(?<partial>\S*)('|")/).flatten.uniq
      links_in_file = file_content.scan(/<a.*href=\"(\S*)\".*>(.*)<\/a>/).uniq
      conditions_in_file = file_content.scan(/if (?<condition>.*)%>/).flatten.uniq
      unless_conditions_in_file = file_content.scan(/unless (?<condition>.*)%>/).flatten.uniq
      submit_tags_in_file = file_content.scan(/submit_tag (?<value>.*),/).flatten.uniq

      file_name = "#{file.gsub('app/', 'spec/')}_spec.rb"
      final_text = "require '#{require_helper_string}'\n\n"
      final_text << "describe '#{file.gsub('app/views/', '')}', :type => :view do\n"
      final_text << "  let(:page) { Capybara::Node::Simple.new(rendered) }\n\n"

      objects_in_file.each do |object|
        final_text << "  let(:#{object}) { '#{object}' }\n"
      end
      
      final_text << "\n  subject { page }\n\n"
      final_text << "  before do\n"

      objects_in_file.each do |object|
        final_text << "    assign(:#{object}, #{object})\n"
      end

      final_text << "    render\n"
      final_text << "  end\n\n"

      final_text << "  describe 'content' do\n"

      fields_in_file.each do |field_name|
        final_text << "    it { is_expected.to have_field '#{ field_name }' }\n"
      end  

      submit_tags_in_file.each do |field_name|
        final_text << "    it { is_expected.to have_css \"input[type='submit'][value=#{ field_name }]\" }\n"
      end  

      templates_in_file.each do |template_name|
        template_path_elements = template_name.split('/')
        template_path_elements.last.gsub!(/^/, '_')

        final_text << "    it { is_expected.to render_template '#{ template_path_elements.join('/') }' }\n"
      end

      partials_in_file.each do |partial_name|
        final_text << "    it { is_expected.to render_template(:partial => '#{ partial_name }') }\n"
      end

      links_in_file.each do |link|
        final_text << "    it { is_expected.to have_link '#{link[1]}', :href => '#{link[0]}' }\n"
      end

      conditions_in_file.each do |condition|
        final_text << "    pending 'if #{condition.strip}'\n"
      end

      unless_conditions_in_file.each do |condition|
        final_text << "    pending 'unless #{condition.strip}'\n"
      end

      final_text << "    pending 'view content test'\n"
      final_text << "  end\n"
      final_text << "end\n"

      check_if_spec_folder_exists

      if File.exists?(Rails.root.join(file_name))
        if File.open(Rails.root.join(file_name)).read == final_text
          # nothing to do here, pre-existing content is the same :)
        else
          puts ('#'*100).colorize(:light_blue)
          puts ("Please, check whether the following lines are included in: " + file_name).colorize(:light_blue)
          puts ('#'*100).colorize(:light_blue)
          puts final_text
          puts "\n\n"
        end
      else
        puts "Producing view spec file for: #{file_name}".colorize(:green)
        f = File.open(file_name, 'wb+')
        f.write(final_text)
        f.close
      end
    end

    nil
  rescue Exception => e
    puts "Exception '#{e}' was raised. Skipping view specs production.".colorize(:red)
  end

  def self.produce_specs_for_helpers
    helpers_list = ActionController::Base.modules_for_helpers(ActionController::Base.all_helpers_from_path 'app/helpers')

    helpers_list.each do |helper|
      file_name = "spec/helpers/#{helper.name.gsub("::", "/").underscore}_spec.rb"
      full_path = 'spec'
      file_name.gsub("spec/", "").split("/").each do |path|
        unless /.*\.rb/.match path
          full_path << "/#{path}"

          unless Dir.exists? full_path
            Dir.mkdir(Rails.root.join(full_path))
          end
        end
      end

      final_text = "require '#{require_helper_string}'\n\n"
      final_text << "describe #{helper}, :type => :helper do\n"
      helper.instance_methods.each do |method_name|
        final_text << "  pending '#{method_name.to_s}'\n"
      end

      final_text << "end"

      check_if_spec_folder_exists

      if File.exists?(Rails.root.join(file_name))
        if File.open(Rails.root.join(file_name)).read == final_text
          # nothing to do here, pre-existing content is the same :)
        else
          puts ('#'*100).colorize(:light_blue)
          puts ("Please, check whether the following lines are included in: " + file_name).colorize(:light_blue)
          puts ('#'*100).colorize(:light_blue)
          puts final_text
          puts "\n\n"
        end
      else
        puts "Producing helper spec file for: #{file_name}".colorize(:green)
        f = File.open(file_name, 'wb+')
        f.write(final_text)
        f.close
      end
    end

    nil
  rescue Exception => e
    puts "Exception '#{e}' was raised. Skipping helper specs production.".colorize(:red)
  end

  def self.produce_specs_for_mailers
    files_list = Dir["app/mailers/**/*.rb"]

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
      final_text << "describe #{File.basename(file, ".rb").camelcase}, :type => :mailer do\n"
      final_text << "  pending 'mailer tests'\n"
      final_text << "end"

      check_if_spec_folder_exists

      if File.exists?(Rails.root.join(file_name))
        if File.open(Rails.root.join(file_name)).read == final_text
          # nothing to do here, pre-existing content is the same :)
        else
          puts ('#'*100).colorize(:light_blue)
          puts ("Please, check whether the following lines are included in: " + file_name).colorize(:light_blue)
          puts ('#'*100).colorize(:light_blue)
          puts final_text
          puts "\n\n"
        end
      else
        puts "Producing helper spec file for: #{file_name}".colorize(:green)
        f = File.open(file_name, 'wb+')
        f.write(final_text)
        f.close
      end
    end

    nil
  rescue Exception => e
    puts "Exception '#{e}' was raised. Skipping mailer specs production.".colorize(:red)
  end

  def self.produce_specs_for_jobs
    files_list = Dir["app/jobs/**/*.rb"]

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
      final_text << "describe #{File.basename(file, ".rb").camelcase}, :type => :job do\n"
      final_text << "  include ActiveJob::TestHelper\n\n"
      final_text << "  subject(:job) { described_class.perform_later(123) }\n\n"
      final_text << "  it 'queues the job' do\n"
      final_text << "    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)\n"
      final_text << "  end\n\n"
      final_text << "  it 'is in proper queue' do\n"
      final_text << "    expect(#{File.basename(file, ".rb").camelcase}.new.queue_name).to eq('default')\n"
      final_text << "  end\n\n"
      final_text << "  pending 'executes perform' do\n"
      final_text << "    perform_enqueued_jobs { job }\n"
      final_text << "  end\n\n"
      final_text << "  after do\n"
      final_text << "    clear_enqueued_jobs\n"
      final_text << "    clear_performed_jobs\n"
      final_text << "  end\n"
      final_text << "end"

      check_if_spec_folder_exists

      if File.exists?(Rails.root.join(file_name))
        if File.open(Rails.root.join(file_name)).read == final_text
          # nothing to do here, pre-existing content is the same :)
        else
          puts ('#'*100).colorize(:light_blue)
          puts ("Please, check whether the following lines are included in: " + file_name).colorize(:light_blue)
          puts ('#'*100).colorize(:light_blue)
          puts final_text
          puts "\n\n"
        end
      else
        puts "Producing job spec file for: #{file_name}".colorize(:green)
        f = File.open(file_name, 'wb+')
        f.write(final_text)
        f.close
      end
    end

    nil
  rescue Exception => e
    puts "Exception '#{e}' was raised. Skipping job specs production.".colorize(:red)
  end

  def self.produce_specs_for_serializers
    Dir.glob(Rails.root.join('app/serializers/*.rb')).each do |x|
      require x
    end

    not_valid_descendants = [ ActiveModel::Serializer::ErrorSerializer ]

    ActiveModel::Serializer.descendants.reject { |descendant| not_valid_descendants.include? descendant }.each do |descendant|
      final_text = "require '#{require_helper_string}'\n\n"
      final_text << "describe #{descendant.name}, :type => :serializer do\n"

      final_text << "  describe 'serializer tests' do\n"
      final_text << "    subject { #{descendant.name}.new(FactoryGirl.build(:#{descendant.name.underscore.gsub('_serializer', '')})) }\n\n"
      final_text << "    it 'includes the expected attribute keys' do\n"
      final_text << "      expect(subject.attributes.keys).to contain_exactly(#{descendant._attributes.map { |x| ":#{x.to_s}" }.join(', ')})\n"
      final_text << "    end\n\n"

      final_text << "    describe 'to_json'\n"
      final_text << "      subject { JSON.parse(#{descendant.name}.new(FactoryGirl.build(:#{descendant.name.underscore.gsub('_serializer', '')})).to_json) }\n\n"

      final_text << "      it 'has the proper values' do\n"

      descendant._attributes.map do |x|
        final_text << "        expect(subject['#{x}']).to eq('')\n"
      end
      
      final_text << "    end\n"
      final_text << "  end\n"
      final_text << "end"

      if File.exists?(Rails.root.join("spec/serializers/#{descendant.name.underscore}_spec.rb"))
        if File.open(Rails.root.join("spec/serializers/#{descendant.name.underscore}_spec.rb")).read == final_text
          # nothing to do here, pre-existing content is the same :)
        else
          puts ('#'*100).colorize(:light_blue)
          puts ("Please, check whether the following lines are included in: " + descendant.name.underscore + "_spec.rb").colorize(:light_blue)
          puts ('#'*100).colorize(:light_blue)
          puts final_text
          puts "\n\n"
        end
      else
        check_if_spec_folder_exists

        unless Dir.exists? Rails.root.join("spec/serializers")
          puts "Generating spec/serializers directory".colorize(:yellow)
          Dir.mkdir(Rails.root.join("spec/serializers"))
        end

        path = "spec/serializers/#{descendant.name.underscore}_spec.rb"
        puts "Producing serializer spec file for: #{path}".colorize(:green)
        f = File.open("#{Rails.root.join(path)}", 'wb+')
        f.write(final_text)
        f.close
      end
    end

    nil
  rescue Exception => e
    puts "Exception '#{e}' was raised. Skipping serializer specs production.".colorize(:red)
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

      check_if_spec_folder_exists

      if File.exists?(Rails.root.join(file_name))
        if File.open(Rails.root.join(file_name)).read == final_text
          # nothing to do here, pre-existing content is the same :)
        else
          puts ('#'*100).colorize(:light_blue)
          puts ("Please, check whether the following lines are included in: " + file_name).colorize(:light_blue)
          puts ('#'*100).colorize(:light_blue)
          puts final_text
          puts "\n\n"
        end
      else
        puts "Producing controller spec file for: #{file_name}".colorize(:green)
        f = File.open(file_name, 'wb+')
        f.write(final_text)
        f.close
      end
    end

    nil
  rescue Exception => e
    puts "Exception '#{e}' was raised. Skipping controller specs production.".colorize(:red)
  end

  #######
  private
  #######

  def self.produce_association_options(reflection)
    return if reflection.options.empty?

    final_text = []

    reflection.options.each_pair do |key, value|
      final_text << case key
                      when :inverse_of then "inverse_of(:#{value})"
                      when :autosave then "autosave(#{value})"
                      when :through then "through(:#{value})"
                      when :class_name then "class_name('#{value}')"
                      when :foreign_key then "with_foreign_key('#{value}')"
                      when :primary_key then "with_primary_key('#{value}')"
                      when :source then "source(:#{value})"
                      when :dependent then "dependent(:#{value})"
                    end
    end
    final_text.reject(&:nil?).join('.').prepend('.')
  end

  def self.require_helper_string
    @require_helper_string ||= collect_helper_strings
  end

  def self.collect_helper_strings
    spec_files = Dir.glob(Rails.root.join('spec/**/*_spec.rb'))
    helper_strings_used = []

    spec_files.each do |file|
      helper = /require \'(?<helpers>\S*)\'/.match File.read(file)

      helper_strings_used << helper[1] if helper.present?
    end

    helper_strings_used.compact!

    if helper_strings_used.uniq.length == 1
      helper_strings_used.first
    else
      puts "More than one helpers are in place in your specs! Proceeding with 'rails_helpers'.".colorize(:yellow)
      'rails_helper'
    end
  end

  def self.check_if_spec_folder_exists
     unless Dir.exists? Rails.root.join("spec")
        puts "Generating spec directory".colorize(:yellow)
        Dir.mkdir(Rails.root.join("spec"))
      end
  end

  private_class_method :produce_association_options
  private_class_method :require_helper_string
  private_class_method :collect_helper_strings
  private_class_method :check_if_spec_folder_exists
end
