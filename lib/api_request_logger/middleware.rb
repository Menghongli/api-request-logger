module ApiRequestLogger
  class Middleware

    def initialize(app, options={})
      @app = app
    end

    def call(env)
      dup._call(env)
    end

    def _call(env)
      @env = env
      @request = ActionDispatch::Request.new(@env)

      determine_likely_ip_address
      perform_geo_snooping

      save_location_data(env)

      @status, @headers, @body = @app.call(env)

      log_request

      [@status, @headers, @body]
    rescue Exception => exception
      @status = 500
      log_request
      raise(exception)
    end

    private

    def log_request
      h = {
        :method => @request.method,
        :path => @request.path,
        :query_string => sanitize_params(@request.query_string.dup),
        :auth_token => @request.headers['HTTP_X_AUTH_TOKEN'] || @request.params['auth_token'],
        :params => sanitize_params(@request.params.except(:session, :format, :action, :controller, :auth_token, *@request.query_parameters.keys).collect{|x,y| "#{x}=#{y}"}.join("&")),
        :user_agent => @request.user_agent,
        :ip => @env['LIKELY_IP'],
        :city => @env['GEO_DATA'][0],
        :country => @env['GEO_DATA'][1],
        :response_status => @status,
        :referer => @request.try(:referer),
        :timestamp => Time.current.to_i
      }
      h.delete_if {|key, val| val.nil? || val.blank?}

      key = ApiRequestLogger::Helpers::RedisKeyMapper.random_request_key

      if ApiRequestLogger.config.loading_method == :bulk_load
        ApiRequestLogger.redis.sadd(ApiRequestLogger::Helpers::RedisKeyMapper.everydays_request_set, key)
        ApiRequestLogger.redis.hmset(key, *h.to_a.flatten)
      else
        ApiRequestLogger::Workers::StreamImportIntoBigQueryWorker.perform_async(h.to_json)
      end
    end

    def determine_likely_ip_address
      possible_ip_address_locations = [@request.env["HTTP_X_FORWARDED_FOR"], @request.env["HTTP_X_REAL_IP"], @request.try(:remote_ip), @request.try(:ip)]

      possible_ip_address_locations = possible_ip_address_locations.collect do |ip|
        if ip.is_a?(String)
          ip.split(',').collect(&:strip).first
        else
          ip
        end
      end
      possible_ip_address_locations.flatten!

      likely_ip = possible_ip_address_locations.find do |ip|
        ip != "" && ip != nil && ip != "127.0.0.1"
      end

      @env['LIKELY_IP'] = likely_ip
    end

    def sanitize_params(str)
      # strip credit card numbers
      str.gsub!(/(?:\d[ -]*?){13,16}/, '[FILTERED]')

      # strip passwords
      str.gsub!(/(\[?password\]?)=([^&]+)/) { "#{$1}=[FILTERED]" }

      return str
    end

    def perform_geo_snooping
      @env['GEO_DATA'] = lookup_geographic_location(@env['LIKELY_IP'])
    end

    def save_location_data(env)
      env['latitude'] = @env['GEO_DATA'][2]
      env['longitude'] = @env['GEO_DATA'][3]
    end

    def lookup_geographic_location(ip)
      $geoip ||= GeoIP.new(File.join(Rails.root, "config", "GeoLiteCity.dat"))

      if lookup = $geoip.city(ip)
        [lookup.city_name.parameterize, lookup.country_name.parameterize, lookup.latitude, lookup.longitude]
      else
        ['unknown', 'unknown', 'unknown', 'unknown']
      end
    rescue
      ['unknown', 'unknown', 'unknown', 'unknown']
    end

  end
end
