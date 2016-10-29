require "spec_producer/version"
require "spec_producer/missing_files_module"
require "spec_producer/missing_gems_module"
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

    run_spec_tests
  end

  def self.produce_specs_for_models
    SpecProductionModule.produce_specs_for_models

    run_spec_tests 'models'
  end

  def self.produce_specs_for_routes
    SpecProductionModule.produce_specs_for_routes

    run_spec_tests 'routes'
  end

  def self.produce_specs_for_views
    SpecProductionModule.produce_specs_for_views

    run_spec_tests 'views'
  end

  def self.produce_specs_for_controllers
    SpecProductionModule.produce_specs_for_controllers

    run_spec_tests 'controllers'
  end

  def self.produce_specs_for_helpers
    SpecProductionModule.produce_specs_for_helpers

    run_spec_tests 'helpers'
  end

  def self.produce_specs_for_mailers
    SpecProductionModule.produce_specs_for_mailers

    run_spec_tests 'mailers'
  end

  def self.produce_specs_for_jobs
    SpecProductionModule.produce_specs_for_jobs

    run_spec_tests 'jobs'
  end

  def self.produce_specs_for_serializers
    SpecProductionModule.produce_specs_for_serializers

    run_spec_tests 'serializers'
  end

  def self.set_up_necessities
    MissingGemsModule.set_up_necessities
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
    MissingFilesModule.print_missing_serializer_specs(options)
    MissingFilesModule.print_missing_route_specs(options)
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

  def self.print_missing_serializer_specs(options = {})
    MissingFilesModule.print_missing_serializer_specs(options)
  end

  def self.print_missing_route_specs(options = {})
    MissingFilesModule.print_missing_route_specs(options)
  end

  def self.run_spec_tests(type = nil)
    puts "\nRunning related spec tests...\n"

    if type.nil?
      system 'bundle exec rake'
    else
      command = case type
                  when 'controllers' then 'bundle exec rspec spec/controllers'
                  when 'views' then 'bundle exec rspec spec/views'
                  when 'mailers' then 'bundle exec rspec spec/mailers'
                  when 'jobs' then 'bundle exec rspec spec/jobs'
                  when 'routes' then 'bundle exec rspec spec/routes'
                  when 'helpers' then 'bundle exec rspec spec/helpers'
                  when 'models' then 'bundle exec rspec spec/models'
                  else 'bundle exec rspec'
                end

      system command
    end
  end
end
