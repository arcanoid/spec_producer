module SpecProducer
  module Producers
    class ViewsProducer
      prepend Base

      def resources
        Dir["app/views/**/*.erb"].
          map { |file| Resource.new(file, file.gsub('app/views/', ''), 'view') }
      end

      def call(resource)
        builder.pending 'view content test'
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