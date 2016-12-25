require 'active_record'

module SpecProducer
  module Producers
    class SerializersProducer
      prepend Base

      def resources
      	[]
      end

      def call(resource)
      end
    end
  end
end