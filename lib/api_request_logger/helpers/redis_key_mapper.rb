module ApiRequestLogger
  module Helpers
    module RedisKeyMapper
      class << self
        def everydays_requests_set(exporting = nil)
          [redis_namespace, "requests", Data.today.strftime('%Y%m%d'), exporting].compact.join(':')
        end

        def legacy_everydays_requests_set
          [redis_namespace, "requests", 'legacy', SecureRandom.hex].compact.join(':')
        end

        def random_request_key
          [redis_namespace, "request", SecureRandom.base64(15)].compact.join(':')
        end

        private

        def redis_namespace
          ApiRequestLogger.config.redis_namespace
        end
      end
    end
  end
end
