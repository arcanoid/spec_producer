module SpecProducer
  module RspecBuilders
    module Matchers
      # \RspecBuilders \Matchers
      # Provides some helper methods to build Rspec matchers.

      # AR reflections to RSpec mathcers
      REFLECTION_MACRO_MAPPINGS = {
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

      MATCHERS = {
        presence: -> (name) {"is_expected.to validate_presence_of(:#{name})" },
        belong_to: ->(name) { "is_expected.to belong_to(:#{name})" },
        have_one: ->(name) { "is_expected.to have_one(:#{name})" },
        has_many: ->(name) { "is_expected.to have_many(:#{name})" },
        db_column: ->(name) { "is_expected.to have_db_column(:#{name})" },
      }

      def M(type)
        MATCHERS[type]
      end

      # Writes an expectation for an AR association given an AR reflection.
      # Example
      #
      #   class User < ActiveRecord::Base
      #     has_many :posts, class_name: 'Post', dependent: :destroy
      #   end
      #   
      #   user_reflection = User.reflections.first
      #   puts has_assosication(user_reflection)
      #     => it { is_expected.to have_many(:posts).class_name(:Post).dependent(:destroy) }
      #
      #   RspecBuilders::Base.build do |b|
      #     b.it { has_associations(user_reflection) }
      #   end
      def has_association(reflection)
        matcher = "#{REFLECTION_MACRO_MAPPINGS[reflection.macro.to_sym]}(:#{reflection.name})"
        options = association_options_for(reflection)
        matcher += options if options.present?
        expectation = "it { is_expected.to #{matcher} }"
        write expectation
        new_line
      end

      def json_parse_for_serialized_object(object)
        "JSON.parse(#{object.name}.new(#{factory_build_for_object(object)}).to_json)"
      end

      def initialize_serializer_for_object(object)
        "#{object.name}.new(#{factory_build_for_object(object)})"
      end

      def factory_build_for_object(object)
        "FactoryGirl.build(:#{object.name.underscore.gsub('_serializer', '')})"
      end

      def association_options_for(reflection)
        return if reflection.options.empty?
        options = []

        reflection.options.each_pair do |key, value|
          options << (SpecProducer::RspecBuilders::Matchers::REFLECTION_MACRO_MAPPINGS[key] || key.to_s) + "(:#{value})"
        end
        options.reject(&:nil?).join('.').prepend('.')
      end
      private :association_options_for

      # Writes all responds_to expectations for the fiven arguments.
      #
      # Example:
      #   
      #   RspecBuilders::Base.build do |b|
      #     b.it { responds_to(:name, :age) }
      #     # or
      #     b.responds_to(:name, :age)
      #   end
      # 
      #   will produce
      #   it { is_expected.to respond_to(:name, :age) }
      #
      def responds_to(*args)
        args = args.map!{ |arg| ":#{arg.gsub(":", '')}" }.split.join(',')
        it "is_expected.to respond_to(#{args})"
        new_line
      end

      # provides a should_be_* matchers
      #
      # Example
      #   RspecBuilders::Base.build do |b|
      #     b.should_be(:present)
      #     b.it { should_be(:valid) }
      #   end
      #
      # will produce:
      #   it { is_expected.to be_present }
      #   it { is_expected.to be_valid }
      #
      def should_be(type)
        it "is_expected.to be_#{type}"
        new_line
      end

      # Given a validator naeme (ex. present) and the attribute
      # validate it will produce the corresponding shoulda matcher
      #
      # Example
      #   
      #   RspecBuilders::Base.build do |b|
      #     b.validates_with(:presence, :name)
      #     b.it { vlaidates_with(:presence, :age) }
      #   end
      #
      # Will produce
      # it { is_expected.to validate_presence_of(:name) }
      # it { is_expected.to validate_presence_of(:age) }
      #
      # Currently no validation options are supported.
      # We should probably change the method to accept an
      # <tt>ActiveModel</tt> validator instead like we do
      # with association expectation where we accept an
      # <tt>ActiveRecord::Reflection</tt>
      #
      def validates_with(kind, attr)
        it "is_expected.to validate_#{kind}_of(:#{attr})"
        new_line
      end

      # Combine the methods below to add an Rspec like
      # expectation. 
      #
      # Example
      #
      #   var = 10
      #   RspecBuidlers::Base.build do
      #     it { expect('subject.age').to eq var }
      #     it { expect('subject.name').to eq 'me' }
      #   end
      #
      #############################################
      # it { expect(some).to eq instance.age }
      def expect(attr)
        @_expected = attr
        self
      end
      def to actual
        it "expect(#{@_expected}).to eq(#{actual})"
        new_line
      end
      def eq(value)
        value
      end
      #############################################

      # Given an name atrribute it writes the: 
      # Example
      #   builder.should_validate_presence_of('age')
      #
      # Produes
      #   it { is_expeted.to validate_presnce_of(:age) }
      #
      def should_validate_presence_of(name)
        expectation = M(:presence)[name]
        it(expectation)
        new_line
      end
      alias_method :validates_presence_of, :should_validate_presence_of

      # Given a :user attribute it writes the belongs to expectation
      # 
      # Example
      #   builder.should_belong_to(:user)
      #
      # Produces
      #   it { is_expected.to belong_to(:user) }
      #
      def should_belong_to(name)
        expectation = M(:belong_to)[name]
        it(expectation)
        new_line
      end

      # Should have one shoulda matcher producer
      #
      # Example
      #   builder.should_have_one(:profile)
      #
      # Produces
      #   it { is_expected.to have_one(:profile) }
      #
      def should_have_one(name)
        expectation = M(:have_one)[name]
        it(expectation)
        new_line
      end

      # have_many shoulda matcher expectation
      #
      # Example
      #   builder.should_have_many(:posts)
      #
      # Produces
      #   it { is_expected.to have_many(:posts) }
      #
      def should_have_many(name)
        expectation = M(:has_many)[name]
        it(expectation)
        new_line
      end
      alias_method :has_many, :should_have_many

      # have_db_column spec producer
      #
      # example
      #   builder.has_db_column(:user_id)
      #
      # produces
      #   it { is_expected.to have_db_column(:user_id) }
      #
      def has_db_column(name)
        expectation = M(:db_column)[name]
        it(expectation)
        new_line
      end

      # Factories spec producer
      # Given the resource name of the factory to build
      # it checks to see if a valid factory exists for the resource name
      #
      # example
      #   
      #   build.has_valid_factory(:user)
      #
      # produces
      #   it { expect(FactoryGirl.build(:user)).to be_valid }
      #
      def has_valid_factory(name)
        it "expect(FactoryGirl.build(:#{name})).to be_valid"
        new_line
      end
    end
  end
end
