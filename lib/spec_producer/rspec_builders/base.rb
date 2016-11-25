require_relative 'matchers'
require_relative 'builder'
module SpecProducer
  module RspecBuilders
    # == Spec \Producer \Rspec \Builders
    #
    # Provides all the the methods required to produce an RSpec string in
    # order to create the corresponding spec files. The base class
    # includes some methods to create a string like <tt>add</tt> method.
    #
    # An example on how to build a spec would be:
    #   resource = SomeResource.new ...
    #
    #   def for_each_column
    #     resource.column_names.each { |c| yield(c) }
    #   end
    #   def for_each_attr
    #     resource.attributes.each { |a| ield(a) }
    #   end
    #
    #   # Build the spec text
    #   text = RspecBuilder::Base.build do |b|
    #     b.write('require \'spec_helper\'')
    #     b.spec(resource.class.name, 'models') do
    #       b.subject { build(#{resource.class.name.underscore}) }
    #       b.context '#respond_to?' do
    #         for_each_attr do |attr|
    #           b.responds_to(attr)
    #         end
    #       end
    #       b.context 'DB columns' do
    #         for_each_column { |c|
    #           b.responds_to(c)
    #         }
    #       end
    #       b.context 'some other context' do
    #         b.subject { 'foo' }
    #         b.it { expect('subject').to eq 'foo' }
    #         context 'a nested context' do
    #           b.subject { 'create(:user).profile' }
    #           b.it { should_be(:present) }
    #         end
    #       end
    #     end
    #   end
    #
    #   # Write the generated text to spec_file
    #   Utils::FileUtils.try_to_create_spec_file('models', resource.class.name.underscore, text)
    #
    #   puts text
    #
    # =>  require 'spec_helper'
    #     describe SomeResource, type: :model do
    #       subject { builder(:resource) }
    #       context '#responds_to?' do
    #         it { is_expected.to respond_to(:attr1) }
    #         it { is_expected.to respond_to(:attr2) }
    #       end
    #
    #       context 'DB columns' do
    #         it { is_expected.to have_db_column(:email) }
    #         it { is_expected.to respond_to(:name) }
    #       end
    #
    #       context 'some other context' do
    #         subject { 'foo' }
    #         it { expect(subject).to eq 'foo' }
    #
    #         context 'a nested context' do
    #           subject { create(:user).profile }
    #           it { expect(subject).to be_present }
    #         end
    #       end
    #     end
    #
    # Note that intentation is automatially done based on the current block
    # we are.
    class Base
      include Matchers
      include Builder

      attr_reader :_text
      attr_reader :intend
      private :intend

      def initialize(t = "")
        @_text = t.to_s
        @intend = 0

        yield self if block_given?
      end

      # Adds a string to buffer. by default auto intent is handled here
      # In order to bypas it we pas false as the current argument. For 
      # example when we add a new line we don't want to add a n times tabs
      #
      def add(text, add_intent = true)
        add_tabs if add_intent == true

        _text << text
        self
      end
      alias_method :<<, :add
      alias_method :append, :add
      alias_method :write, :add

      # Flushes the current buffer to an empty String. Also reset
      # <tt>intend</tt> count to zero.
      #
      def flush!
        @_text = ""
        @intend = 0
      end

      # Adds <tt>@_intend</tt> tabs to the buffer.
      #
      def add_tabs
        intend.times { _text << '  ' }
      end

      # Adds a new line to the buffer
      #
      def new_line
        add "\n", false
      end

      def to_s
        _text
      end

      def inspect
        to_s
      end

      private
      # Increases and decreases the intentation counter. We increase the counter
      # when we are on nested contexts like nested context block.
      def increase_intent
        @intend += 1
      end

      def decrease_intent
        @intend -= 1
      end

    end
  end
end
