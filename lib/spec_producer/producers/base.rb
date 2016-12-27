require 'spec_producer/utils'
# Base module that needs to be included and implemented by
# corresponding producers. Note: This module should be prepended and
# not included / extended.
#
# Concrete subclasses need to implement 2 methods: call and resources
# We use the prepend and prepended callback in order to call Base#call
# method first and the invoke super which will call the corresponding
# concrete implementation to be executed. The #call method on every concrete
# implementation will receive the resource that we currently iterate over.
#
# Conrete implementation need to prepend this module and to provide
# #resources method which returns a collection of resources that
# will be iterated in order to generate the specs for. the resource
# object should respond to #name (ex. Some::User) and #type ('models', 'controllers' etc)
# We need these values in order to generate the Describe 'Some::Person' in rspec files.
#
# A minimal implementation could be
#
#   class SomeSpecProducer
#     prepend Base
#
#     def resources
#       [Clas.new(Object), Class.new(Object)].map { |obj|
#         Resource.new(obj, obj.name, 'models') 
#       }
#     end
#
#
#     def call(resource)
#       builder.context 'Some context' do |b|
#         resource.attributes.each do |attr|
#           b.responds_to(attr)
#         end
#       end
#     end
#   end
#
# The base class is also responsible to write for each spec file that we generate
# the top static lines requiring 'spec_helper' and the beginning of spec file:
#   
#   require 'spec_helper'
#   describe User, type: :model  do
#     # Other code omitted
#   end
#
# Each concrete instance is responsible to create the `body` of the spec file which includes
# its basic validations if any or any other info that we might get from ActiveRecord, ActionController
# etc.
#
# Finally this class is responsible to write the generated spec to the corresponsing
# path (ex spec/models/user_spec.rb)
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
      attr_reader :builder

      def initialize(type)
        @type = type
        @builder = RspecBuilders::Base.new
      end

      def call
        raise(NotImplementedError.new('Abstract method.')) unless defined?(super)
        warn "No resources available" if resources.empty?

        resources.each do |resource|
          builder.build do |b|
            b.write(helper_spec_file)
            b.spec resource.name, resource.type do |b|
              super(resource)
            end
          end

          # Footer / Fils Close etc
          Utils::FileUtils.try_to_create_spec_file(resource.type.pluralize, resource.name.underscore, builder)
          builder.flush!
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

      #######
      private
      #######

      def handle_exception(e)
        puts "Exception '#{e}' was raised. Skipping specs production.".colorize(:red)

        raise e if SpecProducer.configuration.raise_errors
      end

      def helper_spec_file
        "require \'#{require_helper_string}\'\n"
      end

      def rspec_describe(klass, type)
        "describe #{klass}, :type => :#{type} do"
      end
    end
  end
end
