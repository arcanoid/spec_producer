module SpecProducer
  module Producers
    class ControllersProducer
      prepend Base

      def resources
        (ApplicationController.descendants << ApplicationController).
        reverse.
        map { |desc| Resource.new(desc, desc.name, 'controller') }
      end

      def call(resource)
        resource.obj.action_methods.each do |method_name|
          builder.pending method_name
        end
      end

      #######
      private
      #######

      def require_helper_string
        @require_helper_string ||= Utils::FileUtils.collect_helper_strings
      end
    end
  end
end