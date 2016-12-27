module SpecProducer
  module Producers
    class HelpersProducer
      prepend Base

      def resources
      	ActionController::Base.modules_for_helpers(ActionController::Base.all_helpers_from_path 'app/helpers').
        map { |desc| Resource.new(desc, desc.name, 'helper') }
      end

      def call(resource)
        resource.obj.instance_methods.each do |method_name|
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