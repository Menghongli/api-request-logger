module ApiRequestLogger
  class Engine < Rails::Engine

    initializer "api_request_logger.add_middleware" do |app|
      app.middleware.user ApiRequestLogger::Middleware
    end
  end
end
