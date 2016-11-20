require 'active_record'
module SpecProducer
  module Producers
    class ModelsSpecProducer
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
        respond_to_specs(resource.obj.attribute_names) { |spec| write(spec) }
        read_only_attr_specs(resource.obj.readonly_attributes) { |spec| write(spec) }
        print_db_column_specs(resource.obj)

        print_validators_header(resource.obj)
        print_valid_factories(resource.obj)
        print_associations(resource.obj)
      end

      private

      def respond_to_specs(attrs = [])
        return enum_for(:attrs) unless block_given?
        attrs.each do |attr|
          yield "  it { is_expected.to respond_to :#{attr}, :#{attr}= }"
        end
      end

      def read_only_attr_specs(attrs = [])
        return enum_for(:attrs) unless block_given?
        attrs.each do |attr|
          yield "  it { is_expected.to have_readonly_attribute :#{attr} }"
        end
      end

      def print_validators_header(descendant)
        if descendant.validators.reject { |validator| validator.kind == :associated }.present?
          write("\n  # Validators\n")
        end
        descendant.validators.each do |validator|
          validator.attributes.each do |attribute|
            write "  it { is_expected.to validate_#{validator.kind}_of :#{attribute} }\n"
          end
        end
      end

      def print_db_column_specs(descendant)
        if descendant.column_names.present?
          write "\n  # Columns"
        end

        descendant.column_names.each do |column_name|
          write "  it { is_expected.to have_db_column :#{column_name} }"
        end
      end

      def print_valid_factories(desc)
        write ""
        write "  describe 'valid?' do"
        write "    subject { FactoryGirl.build(:#{desc.name.underscore}).valid? }", 2
        write "    it { is_expected.to eq(true) }"
        write "  end", 2
      end

      def produce_association_options(reflection)
        return if reflection.options.empty?
        spec_text.tab
        options = []

        reflection.options.each_pair do |key, value|
          options << (REFL_TO_RSPEC_MAPPINGS[key] || key.to_s) + "(:#{value})"
        end
        options.reject(&:nil?).join('.').prepend('.')
      end

      REFL_TO_RSPEC_MAPPINGS = {
        belongs_to: 'belong_to',
        has_one: 'have_one',
        has_many: 'have_many',
        has_and_belongs_to_many: 'have_and_belongs_to_many',
        inverse_of: 'inverse_of',
        autosave: 'autosave',
        through: 'through',
        class_name: 'class_name',
        foreign_key: 'with_foreign_key',
        primary_key: 'with_primary_key',
        source: 'source',
        dependent: 'dependent'
      }

      def print_associations(descendant)
        if descendant.reflections.keys.present?
          write "\n  # Associations"
        end
        descendant.reflections.each_pair do |key, reflection|
          matcher = REFL_TO_RSPEC_MAPPINGS[reflection.macro]
          footer = produce_association_options(reflection)
          spec_text.tab
          write spec_text.expectation(nil, matcher, key, footer)
        end

        write "end"
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
