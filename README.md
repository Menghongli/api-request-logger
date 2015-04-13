# Api Request Logger

Logging Api Requests using BigQuery And Redis

## Installation

Add this line to your application's `Gemfile`:

    gem 'api_request_logger'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install api_request_logger

After bundling, you should configure ApiRequestLogger. Do this somewhere after you've required it, but before it's actually used. For example, Rails users would create an initializer (`config/initializers/api_request_logger.rb`):

```ruby
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

  config.application_name = "Api_request_logger"
end
```

The values listed above are the defaults.

## Configuration

1. Google api configuration (`config/ga_config.yml`)
```
# Include correct information about the app
project_id: propane-tribute-90023
application_name: 'My Test App'
application_version: 1.0
```

2. `TODO` customize BigQuery Schema

## Usage

Add Sidekiq queue name and weights into `config/sidekiq.yml`
```
:queues:
- [api_request_logger, 4]
```
