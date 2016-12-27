module SpecProducer
  module Configuration
    CURRENT_ATTRS = [:raise_errors].freeze
    DEPRECATED_ATTRS = [].freeze
    CONFIG_ATTRS = (CURRENT_ATTRS + DEPRECATED_ATTRS).freeze

    def configure
      return unless block_given?
      yield config
    end

    def configuration
      config
    end

    def config
      @config ||= Configuration.new
    end
    private :config

    class Configuration < Struct.new(*CONFIG_ATTRS)
      def initialize
        super

        set_default_values
      end

      def options
        Hash[ * CONFIG_ATTRS.map { |key| [key, send(key)] }]
      end

      #######
      private
      #######
      
      def set_default_values
        self.raise_errors = true
      end
    end
  end
end
