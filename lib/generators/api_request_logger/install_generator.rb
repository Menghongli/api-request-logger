module ApiRequestLogger
  module Generators
    class InstallGenerators < Rails::Generators::Base
      source_root File.expend_path("../../templates", __FILE__)

      desc "Creates a ApiRequestLogger initializer and copy google api configuartion files to your configuartion"

      def copy_initializer
        template "api_request_logger.rb", "config/initializers/api_request_logger.rb"
      end

      def copy_ga_config
        copy_file "../../../config/ga_config.yml", "config/ga_config.yml"
      end

    end
  end
end
