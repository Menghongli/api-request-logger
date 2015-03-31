require 'redis'

ApiRequestLogger.configure do |config|
  # BigQuery Loading method
  #
  # Default: bulk_load
  config.loading_method = :bulk_load

  # Connection to Redis
  #
  # Default: localhost:6379
  config.redis = Redis.new(host: 'localhost', port: 6379, db: 0)

  # A prefix for all keys ApiRequestLogger uses
  #
  # Default: api_request_logger
  config.redis_namespace = :api_request_logger
end
