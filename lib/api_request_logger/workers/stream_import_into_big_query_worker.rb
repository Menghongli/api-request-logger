module ApiRequestLogger
  module Workers
    class StreamImportIntoBigQueryWorker
      if defined?(:Sidekiq)
        include ::Sidekiq::Worker
        sidekiq_options :queue => :api_request_logger
      end

      def perform(data)
        response = ApiRequestLogger.stream_import_into_big_query(data)

        if response['insertErrors']['errors']['reason']
          fail response['insertErrors']['errors']['message'].to_s
        end
      end
    end
  end
end
