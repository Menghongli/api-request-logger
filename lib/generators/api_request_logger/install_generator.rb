require 'rails/generators/base'

module ApiRequestLogger
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)

      desc "Creates a ApiRequestLogger initializer and copy google api configuartion files to your configuartion"

      def copy_initializer
        template "api_request_logger.rb", "config/initializers/api_request_logger.rb"
      end

      def copy_ga_config
        copy_file "../../../config/ga_config.yml", "config/ga_config.yml"
      end

      def copy_bq_schema
        copy_file "../../../config/bq_schema.json", "config/bq_schema.json"
      end

      def copy_geo_lite_city
        copy_file "../../../config/GeoLiteCity.dat", "config/GeoLiteCity.dat"
      end

    end
  end
end
