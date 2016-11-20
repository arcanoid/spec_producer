require 'spec_producer/utils'
# Base module that needs to be included and implemented by
# corresponding producers. Note: This module should be prepended and
# not included / extended.
#
# Concrete subclasses need to implemente 2 methods: call and resources
# We use the prepend and prepended callback in order to call Base#call
# method first and the invoke super which will call the corresponding
# concrete implementation to be executed. The #call method on every concrete
# implementation will receive the resource that we currently iterate over.
#
# Conrete implementation need to prepend this module and to provide
# #resources method which returns a collection of resources that
# will be iterated in order to generate the specs for. the resource
# object should respond to #name (ex. Module::User) and #type ('models', 'controllers' etc)
# We need these values in order to generate the Describe 'Some::Person' in rspec files.
#
# A minimal implementation could be
#
#   class SomeSpecProducer
#     prepend Base
#
#     def attributes
#       [Clas.new(Object), Class.new(Object)].map { |obj|
#         Resource.new(obj, obj.name, 'models') 
#       }
#     end
#
#
#     def call(resource)
#       write "it { should be valid }"
#     end
#   end
#
# This base class is also responsible to write for each spec file that we generate
# the top lines like requiring 'spec_helper' or beginning the describe User, type: :model {} 
# block. Each concrete instance is responsible to create the `body` of the spec file which includes
# its basic validations if any or any other info that we might get from ActiveRecord, ActionController
# etc.
#
module SpecProducer
  module Producers
    module Base
      class Resource < Struct.new(:obj, :name, :type)
      end

      module ClassMethods
        def call(args)
          new(args).call
        end
      end

      def self.prepended(base)
        base.extend(ClassMethods)
      end

      attr_reader :type
      attr_reader :spec_text

      def initialize(type)
        # TODO: this is the correct place to load Rails
        # see also spec_helper hacks on rails
        Rails.application.eager_load!

        @type = type
        @spec_text = SpecProducer::RspecText::Base.new
      end

      def call
        raise(NotImplementedError.new('Abstract method.')) unless defined?(super)
        resources.each do |resource|
          # htop
          write helper_spec_file, new_lines = 2
          write rspec_describe(resource.name, resource.type), new_lines = 1

          super(resource)

          # Footer / Fils Close etc
          Utils::FileUtils.try_to_create_spec_file('models', resource.name.underscore, spec_text)
          flush!
        end

        self

      rescue StandardError => e
        handle_exception(e)
      end

      # @Abstract method
      def resources
        raise(NotImplementedError.new('Abstract method.')) unless defined?(super)
        super
      end

      def write(string, new_lines = 1)
        spec_text.add(string).send("with_#{new_lines}_lines")
      end

      def flush!
        spec_text.flush!
      end

      private
      def handle_exception(e)
        raise e if SpecProducer.configuration.raise_errors
        puts "Exception '#{e}' was raised. Skipping model specs production.".colorize(:red)
      end

      def helper_spec_file
        "require \"#{require_helper_string}\""
      end

      def rspec_describe(klass, type)
        "describe #{klass}, :type => :#{type} do"
      end
    end
  end
end
