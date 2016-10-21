require "spec_producer/version"
require "spec_producer/missing_files_module"
require "spec_producer/spec_production_module"
require "spec_producer/factories_production_module"

module SpecProducer
  def self.produce_specs_for_all_types
    SpecProductionModule.produce_specs_for_models
    SpecProductionModule.produce_specs_for_routes
    SpecProductionModule.produce_specs_for_views
    SpecProductionModule.produce_specs_for_controllers
    SpecProductionModule.produce_specs_for_helpers
    SpecProductionModule.produce_specs_for_mailers
    SpecProductionModule.produce_specs_for_jobs
    SpecProductionModule.produce_specs_for_serializers
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

  def self.produce_specs_for_mailers
    SpecProductionModule.produce_specs_for_mailers
  end

  def self.produce_specs_for_jobs
    SpecProductionModule.produce_specs_for_jobs
  end

  def self.produce_specs_for_serializers
    SpecProductionModule.produce_specs_for_serializers
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
      missing_gems << 'webmock' unless (gems.include? 'webmock')
      missing_gems << 'rubocop' unless (gems.include? 'rubocop')  

      # No need for capybara if there are no views to parse
      missing_gems << 'capybara' unless ((gems.include? 'capybara') && Dir["app/views/**/*.erb"] != [])

      if missing_gems.size > 0
        actions_needed = "You will additionally need to:\n"
        useful_info = ''
        contents << "\ngroup :test do\n"

        missing_gems.each do |gem|
          contents << "  gem '#{gem}'\n"

          if gem == 'rspec-rails'
            actions_needed << "# Run 'rails generate rspec:install' (More info: https://github.com/rspec/rspec-rails)\n"
          elsif gem == 'factory_girl_rails'
            useful_info << "# FactoryGirl: https://github.com/thoughtbot/factory_girl_rails\n"
          elsif gem == 'shoulda-matchers'
            useful_info << "# Shoulda Matchers: https://github.com/thoughtbot/shoulda-matchers\n"
          elsif gem == 'webmock'
            actions_needed << "# Add 'require \'webmock/rspec\'' in your spec_helper or rails_helper\n"
            useful_info << "# Webmock: https://github.com/bblimke/webmock\n"
          elsif gem == 'rubocop'
            useful_info << "# RuboCop: https://github.com/bbatsov/rubocop\n"
          end
        end

        contents << "end"
      end

      f = File.open(gemfiles.first, 'wb+')
      f.write(contents)
      f.close

      puts actions_needed
      puts useful_info
    else
      puts "We couldn't find a Gemfile and setting up halted!"
    end
  end

  def self.produce_factories
    FactoriesProductionModule.produce_factories
  end

  def self.print_all_missing_spec_files(options = {})
    MissingFilesModule.print_missing_model_specs(options)
    MissingFilesModule.print_missing_controller_specs(options)
    MissingFilesModule.print_missing_helper_specs(options)
    MissingFilesModule.print_missing_view_specs(options)
    MissingFilesModule.print_missing_mailer_specs(options)
    MissingFilesModule.print_missing_job_specs(options)
  end

  def self.print_missing_model_specs(options = {})
    MissingFilesModule.print_missing_model_specs(options)
  end

  def self.print_missing_controller_specs(options = {})
    MissingFilesModule.print_missing_controller_specs(options)
  end

  def self.print_missing_helper_specs(options = {})
    MissingFilesModule.print_missing_helper_specs(options)
  end

  def self.print_missing_view_specs(options = {})
    MissingFilesModule.print_missing_view_specs(options)
  end

  def self.print_missing_mailer_specs(options = {})
    MissingFilesModule.print_missing_mailer_specs(options)
  end

  def self.print_missing_job_specs(options = {})
    MissingFilesModule.print_missing_job_specs(options)
  end
end
