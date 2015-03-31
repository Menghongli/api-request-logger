require "api_request_logger/version"
require "api_request_logger/configuration"

module ApiRequestLogger
  class << self
    def redis
      config.redis
    end

    def dump
      if @redis.exists('requests')
        prepare_set_for_exporting

        filename = File.join(Rails.root, 'big_query_dumps', "api_requests_#{Time.current.to_i}.json.gz")
        Zlib::GzipWriter.open(filename) do |log|
          while key = @redis.spop('requests:exporting')
            r = @redis.hgetall(key)
            log.puts( r.to_json )
            @redis.del(key)
          end
        end

      end

      filename
    end

  end
end
