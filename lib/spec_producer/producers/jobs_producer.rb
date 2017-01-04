module SpecProducer
  module Producers
    class JobsProducer
      prepend Base

      def resources
        Dir["app/jobs/**/*.rb"].
          map { |file| Resource.new(file, File.basename(file, ".rb").camelcase, 'job') }
      end

      def call(resource)
        builder.subject('described_class.perform_later(123)')

        builder.context('queues the job') do
          builder.it("expect(subject).to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)")
        end

        builder.context('is in proper queue') do
          builder.it("expect(#{resource.name}.new.queue_name).to eq('default')")
        end

        builder.pending 'executes perform'
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