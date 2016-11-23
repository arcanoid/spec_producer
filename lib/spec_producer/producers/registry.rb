module SpecProducer
  module Producers
    class Registry
      include Enumerable
      attr_reader :registrations

      delegate :any?, :empty?, :size, :length, to: :registrations

      def initialize
        @registrations = Set.new
      end

      def register(spec_type, klass)
        registrations << Registration.new(spec_type, klass)
      end

      def each
        return enum_for(:registrations) { registrations.size } unless block_given?
        registrations.each { |registration| yield(registration) }
      end

      def types
        map(&:name)
      end
      alias_method :registerd_types, :types

      def registered?(symbol)
        !!find_registration(symbol)
      end

      def lookup!(symbol)
        registration = find_registration(symbol)

        if registration
          registration.call(symbol)
        else
          raise ArgumentError, "Unknown spec type #{symbol.inspect}"
        end
      end

      private
      def find_registration(symbol)
        registrations.find { |r| r.matches?(symbol) }
      end
    end

    class Registration
      attr_reader :name, :klass

      def initialize(name, klass)
        @name = name
        @klass = klass
      end

      def matches?(type_name)
        type_name == name
      end

      def call(args)
        klass.call(args)
      end

      protected
    end
  end
end
