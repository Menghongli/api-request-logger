module ApiRequestLogger
  module Helpers
    module RedisKeyMapper
      class << self
        def everydays_request_set
          [redis_namespace, "requests", Data.today.strftime('%Y%m%d')].compact.join(':')
        end

        private

        def redis_namespace
          ApiRequestLogger.config.redis_namespace
        end
      end
    end
  end
end
