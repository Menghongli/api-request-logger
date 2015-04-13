module ApiRequestLogger
  module Workers
    class DumpBigQueryDataWorker
      if defined?(:Sidekiq)
        include ::Sidekiq::Worker
        sidekiq_options :queue => :api_request_logger
      end

      def perform
        @filename = ApiRequestLogger.dump
        ApiRequestLogger::Workers::UploadBigQueryWorker.perform_async(@filename) unless @filename.nil?
      end
    end
  end
end
