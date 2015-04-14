# Api Request Logger

Logging Api Requests using BigQuery And Redis

## Requirements
* Redis
* Sidekiq
* Sidekiq-cron
* Google Api Client

## Getting started

Add this line to your application's `Gemfile`:
```ruby
gem 'api_request_logger'
```

After bundling, you need to run the generator
```ruby
rails generate api_request_logger:install
```
The generator will install an initializer which contains all of api_request_logger's configuration opstions.(`config/initializers/api_request_logger.rb`):

```ruby
require 'redis'

ApiRequestLogger.configure do |config|
  # BigQuery Loading method
  # Options: bulk_load, stream_load
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

### Credentials
* Download your application default credentials from `Google Developers Console`
* Set the environment variable GOOGLE_APPLICATION_CREDENTIALS to the path of the JSON file downloaded
```
ENV['GOOGLE_APPLICATION_CREDENTIALS'] = '/src/api_request_logger/config/YOUR-APP-CREDENTIALS.json'
```

* `TODO` customize BigQuery Schema
* Sidekiq-cron: Add into your sidekiq initializer file (`config/initializers/sidekiq.rb`)
```ruby
require 'api_request_logger/workers'

schedule_file = "config/schedule.yml"

if File.exists?(schedule_file)
  Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
end
```

Add the follow job to your schedule file (`config/schedule.yml`) if your are using bulk_load
```yml
# config/schedule.yml
DumpBigQueryDataWorker:
  cron: "*/5 * * * *"
  class: "ApiRequestLogger::Workers::DumpBigQueryDataWorker"
```

## Usage

Add Sidekiq queue name and weights into `config/sidekiq.yml`
```yml
:queues:
- [api_request_logger, 4]
```
