module ApiRequestLogger
  module Workers
    class ImportBigQueryDataWorker
      if defined?(:Sidekiq)
        include ::Sidekiq::Worker
        sidekiq_options :queue => :api_request_logger
      end

      def perform(remote_filename)
        response = ApiRequestLogger.import_into_big_query(remote_filename)

        job_id = response['jobReference']['jobId']
        ga = ApiRequestLogger::GoogleApi.new

        while job = ga.get_job(job_id)
          break if job['status']['state'] == 'DONE'
          sleep(5)
        end

        if job['status']['errorResult']
          fail job['status']['errors'].to_s
        end
      end
    end
  end
end
