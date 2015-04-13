require 'redis'

module ApiRequestLogger
  class Configuration

    # BigQuery Loading method
    #
    # Default: bulk_load
    attr_accessor :loading_method

    # Connection to Redis
    #
    # Default: localhost:6379
    attr_accessor :redis

    # A prefix for all keys ApiRequestLogger uses
    #
    # Default: api_request_logger
    attr_accessor :redis_namespace

    # Application Name
    #
    # Default: api_request_logger
    attr_accessor :application_name

    def initialize
      @loading_method = :bulk_load
      @redis = Redis.new
      @redis_namespace = :api_request_logger
      @application_name = "Api_request_logger"
    end
  end

  class << self
    def configure
      @config ||= Configuration.new
      yield @config
    end

    def config
      @config ||= Configuration.new
    end
  end
end
