module ApiRequestLogger
  class Railtie < Rails::Railtie

    initializer "api_request_logger.configure_rails_initialization" do
      insert_middleware
    end

    def insert_middleware
      app.middleware.use ApiRequestLogger::Middleware
    end

    def app
      Rails.application
    end
  end
end
