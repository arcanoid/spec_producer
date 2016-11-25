require 'active_record'
module SpecProducer
  module Producers
    class ModelsProducer
      prepend Base

      # TODO Rethink this
      CLASSES_TO_IGNORE = ['ActiveRecord::SchemaMigration', 'ApplicationRecord',
                           'Delayed::Backend::ActiveRecord::Job',
                           'ActiveRecord::InternalMetadata']

      def resources
        ActiveRecord::Base.descendants.reject do |descendant|
          should_ignore?(descendant)
        end.map { |desc| Resource.new(desc, desc.name, 'model')  }
      end

      def call(resource)
        builder.context('#respond_to?') do
          respond_to_specs(resource.obj.attribute_names) { |attr| builder.responds_to(attr) }
          read_only_attr_specs(resource.obj.readonly_attributes) { |attr| builder.responds_to(attr) }
        end

        if resource.obj.column_names.present?
          builder.context('DB Columns') do
            resource.obj.column_names.each do |column_name|
              builder.it { has_db_column(column_name) }
            end
          end
        end

        if has_validators?(resource.obj)
          builder.context 'validations' do
            resource.obj.validators.each do |validator|
              validator.attributes.each do |attribute|
                builder.validates_with validator.kind, attribute
              end
            end
          end
        end

        builder.context 'factories' do
          builder.it { has_valid_factory(resource.obj.name.underscore) }
        end

        if resource.obj.reflections.keys.present?
          builder.context 'Associations' do
            resource.obj.reflections.each_pair do |_, reflection|
              builder.it { has_association(reflection) }
            end
          end
        end
      end

      private

      def respond_to_specs(attrs = [])
        return enum_for(:attrs) unless block_given?
        attrs.each do |attr|
          yield(attr)
          yield(":#{attr}=")
        end
      end

      def read_only_attr_specs(attrs = [])
        return enum_for(:attrs) unless block_given?
        attrs.each do |attr|
          yield(attr)
        end
      end

      def has_validators?(desc)
        desc.validators.reject { |validator| validator.kind == :associated }.present?
      end

      def should_ignore?(descendant)
        CLASSES_TO_IGNORE.include?(descendant.to_s)
      end

      def require_helper_string
        @require_helper_string ||= Utils::FileUtils.collect_helper_strings
      end
    end
  end
end
