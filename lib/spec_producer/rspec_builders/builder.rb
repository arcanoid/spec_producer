module SpecProducer
  module RspecBuilders
    module Builder
      # == RspecBuilder \Builder
      #
      # Provides the building blocks to create an rspec text using
      # <tt>RspecProducer::RspecBuilders::Base</tt> class. Currently
      # it supports the following building spec blocks: 
      #


      # Call build on an <tt>RspecBuilder::Base instance</tt>
      #
      # Example
      #   
      #   builder = RspecBuilders::Base.new('Init Text')
      #   builder.build do |b|
      #     # Other method calls here
      #   end
      def build(&block)
        block.call(self)
        self
      end

      # Call build on a <tt>RspecBuilders::Base</tt> class
      #
      # Example
      # 
      #   builder = RspecBuilders::Base.build do |b|
      #     # ...
      #     b.context('my awsome spec') do
      #       be.it { should_be(:valid) }
      #     end
      #   end
      #
      def self.build(&block)
        instance = new
        block.call(instance)
        instance
      end

      # Creates a new spec. This is the header block required by all spec files
      # 
      # Example
      #
      #   builder = RspecBuilders::Base.build do |b|
      #               b.spec 'User', 'models'
      #             end
      #
      #   Calling
      #     puts builder
      #
      #   Returns the following string:
      #
      #     describe User, type: :model do
      #     end
      #
      def spec(klass, type, &block)
        new_line
        add "describe #{klass}, type: :#{type} do"

        increase_intent
        new_line

        block.call(self)

        decrease_intent
        add 'end'
      end

      # Adds a subject { 'some' } block to buffer
      # it also adds a new line for the next spec to be added to the new line
      #
      # Example
      #   
      #   RspecBuilders::Based.build do |b|
      #     b.subject { 'User.new' }
      #   end
      #
      #   Produces:
      #     subject { User.new }
      #
      def subject(s)
        add "subject { #{s} }"
        new_line
      end

      # Adds a pending 'some' block to buffer
      # it also adds a new line for the next spec to be added to the new line
      #
      # Example
      #   
      #   RspecBuilders::Based.build do |b|
      #     b.pending { 'some missing spec' }
      #   end
      #
      #   Produces:
      #     pending 'some missing spec'
      #
      def pending(s)
        add "pending '#{s}'"
        new_line
      end

      # Adds a context or describe (alias) block for the spec.
      # the method is responsible to handle the intentation management 
      # (increase / decrease). 
      #
      # Usage 
      #   
      #   RspecBuilders::Base.build do |b|
      #     b.context 'first context' do
      #       b.context 'first nested' do
      #       end
      #     end
      #
      #     b.context 'second context' do
      #       b.context 'second nested' {}
      #     end
      #   end
      #
      #   Which produces the following spec:
      #
      #   context 'first context' do
      #     context 'first nested' do
      #     end
      #   end
      #
      #   context 'second context' do
      #     context 'second nested do
      #
      #     end
      #   end
      #
      def context(name, &block)
        new_line
        add "context \"#{name}\" do"
        increase_intent
        new_line

        block.call

        decrease_intent
        add 'end'
        new_line
      end
      alias_method :describe, :context

      # Provides an it expectation.
      #
      # Usage example
      #   
      #   user = User.new(name: 'alex', email: 'some@some.com')
      #
      #   RspecBuilders::Base.build do |b|
      #     b.subject { "build(:user, name: 'Alex', email: 'some@some.com')" }
      #
      #     # Matchers provided from RspecBuilders::Matchers
      #     b.it { validates_presence_of(:name) }
      #     b.it { expect('subject.name').to eq user.name }
      #     b.it { expect('subject.email').to eq 'name' }
      #
      #     # Or provide the expecation as a string
      #     b.it('expect(subject).to be_a User')
      #   end
      #
      #   produces the following spec
      #
      #     subject { 'builder(:user, anme: 'Alex', email: 'some@some.com')' }
      #     it { is_expected.to validate_presence_of(:name) }
      #     it { expect(subject.name).to eq 'Alex' }
      #     it { expect(subject.email).to eq 'some@some.com' }
      #     it { expect(subject).to be_a User }
      #
      def it(*args, &block)
        expectation = args.shift
        if expectation
          add "it { #{expectation} }"
        else
          instance_eval(&block)
        end
      end
    end
  end
end
