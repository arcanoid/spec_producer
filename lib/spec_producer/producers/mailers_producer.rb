module SpecProducer
  module Producers
    class MailersProducer
      prepend Base

      def resources
        Dir["app/mailers/**/*.rb"].
          map { |file| Resource.new(file, File.basename(file, ".rb").camelcase, 'mailer') }
      end

      def call(resource)
        builder.pending 'mailer tests'
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