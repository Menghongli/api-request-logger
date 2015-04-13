module ApiRequestLogger
  module Workers
    class UploadBigQueryWorker
      if defined?(:Sidekiq)
        include ::Sidekiq::Worker
        sidekiq_options :queue => :api_request_logger
      end

      def perform(filename)
        @remote_filename = ApiRequestLogger.upload_to_google_cloud(filename)
        File.delete(filename)
        ApiRequestLogger::Workers::ImportBigQueryDataWorker.perform_async(@remote_filename)
      end
    end
  end
end
