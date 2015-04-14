require 'json'

require "api_request_logger/version"
require "api_request_logger/configuration"
require "api_request_logger/helpers"
require "api_request_logger/middleware"
require "api_request_logger/google_api"

module ApiRequestLogger
  class << self
    def redis
      config.redis
    end

    def dump
      requests_set            = ApiRequestLogger::Helpers::RedisKeyMapper.everydays_requests_set
      requests_set_exporting  = ApiRequestLogger::Helpers::RedisKeyMapper.everydays_requests_set("exporting")

      if redis.exists(requests_set)
        prepare_set_for_exporting(requests_set, requests_set_exporting)

        # TODO Create big_query_dumps folder under root
        filename = File.join(Rails.root, 'big_query_dumps', "api_requests_#{Time.current.to_i}.json.gz")
        Zlib::GzipWriter.open(filename) do |log|
          while key = redis.spop(requests_set_exporting)
            r = redis.hgetall(key)
            log.puts( r.to_json )
            redis.del(key)
          end
        end

      end

      filename
    end

    def prepare_set_for_exporting(requests_set, requests_set_exporting)
      if redis.exists(requests_set_exporting)
        # requests:exporting set already exists?
        # merge it with the new data
        a = ApiRequestLogger::Helpers::RedisKeyMapper.legacy_everydays_requests_set
        b = ApiRequestLogger::Helpers::RedisKeyMapper.legacy_everydays_requests_set
        redis.rename(requests_set, a)
        redis.rename(requests_set_exporting, b)
        redis.sunionstore(requests_set_exporting, a, b)
        redis.del(a, b)
      else
        redis.rename(requests_set, requests_set_exporting)
      end
    end

    def import_into_big_query(filename)
      schema_file = IO.read(File.join(Rails.root, 'config', 'bq_schema.json'))
      schema = JSON.parse(schema_file)

      ApiRequestLogger::GoogleApi.new.insert_data(filename, "#{config.application_name}-#{Rails.env}", "api_requests_#{Date.today.strftime('%Y%m%d')}", schema)
    end

    def upload_to_google_cloud(filename)
      remote_file_name = Time.current.strftime("%Y/%b/%d/#{File.basename(filename)}")
      ApiRequestLogger::GoogleApi.new.upload_file(filename, "#{config.application_name}-#{Rails.env}", remote_file_name)
      remote_file_name
    end

    def stream_import_into_big_query(data)
      ApiRequestLogger::GoogleApi.new.stream_data("api_requests_#{Date.today.strftime('%Y%m%d')}", data)
    end

  end
end

require "api_request_logger/rails" if defined? Rails::Railtie
