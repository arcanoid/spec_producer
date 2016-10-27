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
end
