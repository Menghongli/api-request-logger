module ApiRequestLogger
  module Workers
    class StreamImportIntoBigQueryWorker
      if defined?(:Sidekiq)
        include ::Sidekiq::Worker
        sidekiq_options :queue => :api_request_logger
      end

      def perform(data)
        ApiRequestLogger.stream_import_into_big_query(data)
      end
    end
  end
end
