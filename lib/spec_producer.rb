require "spec_producer/version"

require 'spec_producer/railtie'

require "spec_producer/missing_files_module"
require "spec_producer/missing_gems_module"
require "spec_producer/spec_production_module"
require "spec_producer/factories_production_module"

require 'active_support/core_ext/module/delegation'

require 'spec_producer/producers'
require 'spec_producer/rspec_builders'
require 'spec_producer/spec_runner'

require 'configuration'

module SpecProducer
  extend Configuration
  # == Spec \Producer
  # Produces specs for the given type(s)
  #
  # To produce all spec you simply run:
  #   SpecProducer.produce
  #
  # You can provide some options to tell the producer to include or exclude some specs
  # Example with <tt>:include</tt> option
  #
  #   SpecProducer.produce(only: [:models, :controllers])
  #
  # Example with <tt>exclude</tt> option
  #   SpecProducer.produce(except: :views)
  #
  #
  # We can produce specs for a single type by calling 
  #
  #   SpecProducer.produce_spec(:models)
  #
  # 
  # To add a new type of a Producer (Concrete class under spec_producer/producers) for a given type
  # we need to register it in this class. For example if we want to implement ControllersProducer
  # we would register it as follows:
  #
  #   register(:models, Producers::ControllersProducer)
  #
  # This gives as the convention to lookup producers using a symbol and later on we can add
  # extra functionality when registering a producer (optional params, init with lambdas etc.)
  #

  @registry = Producers::Registry.new

  class << self
    attr_reader :registry
    delegate :run, to: SpecRunner

    def produce(*args)
      opts = args.extract_options!
      spec_types = registry.types

      if only = opts[:only]
        spec_types &= Array(only).map(&:to_sym)
      elsif except = opts[:except]
        spec_types -= Array(except).map(&:to_sym)
      end

      # Produce the specs
      spec_types.each { |t| produce_spec(t) }

      # Run the specs
      run(spec_types) if opts[:run_specs]
    end

    def register(type_name, klass)
      registry.register(type_name, klass)
    end

    # Produces a single spec type. For example
    #
    #   SpecProducer.produce_spec(:models)
    #
    # Will fetch and execute the Producers::ModelsSpecProducer
    #
    def produce_spec(spec_type)
      lookup!(spec_type)
    end

    # Fetches the producer from the registry. Note: that the #lookup method
    # on registry instantiates and executes the producer to start generating
    # the spec files. This execution is hidden in repository and the client 
    # is not aware of what is going on underneath. TODO: Refactor this so
    # registry#lookup! does not executes the regitered Producer.
    #
    # If no Producer is Found an ArgumentError exception is thown.
    #
    def lookup!(spec_type)
      registry.lookup!(spec_type)
    end
  end

  # Register new producers
  register(:models, Producers::ModelsProducer)
  register(:views, Producers::ViewsProducer)
  register(:controllers, Producers::ControllersProducer)
  register(:helpers, Producers::HelpersProducer)
  register(:routes, Producers::RoutesProducer)
  register(:mailers, Producers::MailersProducer)
  register(:jobs, Producers::JobsProducer)
  register(:serializers, Producers::SerializersProducer)

  def self.produce_specs_for_all_types
    SpecProductionModule.produce_specs_for_routes
    SpecProductionModule.produce_specs_for_views
    SpecProductionModule.produce_specs_for_controllers
    SpecProductionModule.produce_specs_for_helpers
    SpecProductionModule.produce_specs_for_mailers
    SpecProductionModule.produce_specs_for_jobs
    SpecProductionModule.produce_specs_for_serializers

    run_spec_tests
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
