# Api Request Logger

Logging Api Requests using BigQuery And Redis

## Requirements
* [Redis] Redis
* [sidekiq] Sidekiq
* [sidekiq-cron] Sidekiq-cron
* [google-api-client] Google Api Client

## Installation

Add this line to your application's `Gemfile`:
```ruby
gem 'api_request_logger'
```
And then execute:
```shell
$ bundle
```
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

* Google api configuration (`config/ga_config.yml`)
```yml
# Include correct information about the app
project_id: propane-tribute-90023
application_name: 'My Test App'
application_version: 1.0
```

* `TODO` customize BigQuery Schema
* Sidekiq-cron: Add into your sidekiq initializer file (`config/initializers/sidekiq.rb`)
```ruby
schedule_file = "config/schedule.yml"

if File.exists?(schedule_file)
  Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
end
```

## Usage

Add Sidekiq queue name and weights into `config/sidekiq.yml`
```yml
:queues:
- [api_request_logger, 4]
```
