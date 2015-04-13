# Api Request Logger

Logging Api Requests using BigQuery And Redis

## Installation

Add this line to your application's Gemfile:

    gem 'api_request_logger'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install api_request_logger

## Usage

TODO: Write usage instructions here

please add queue name and weights into config/sidekiq.yml
    :queues:
    - [api_request_logger, 4]
    - [default, 3]
    ...

## Contributing

1. Fork it ( https://github.com/[my-github-username]/./fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
