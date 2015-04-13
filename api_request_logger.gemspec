# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'api_request_logger/version'

Gem::Specification.new do |spec|
  spec.name          = "api_request_logger"
  spec.version       = ApiRequestLogger::VERSION
  spec.authors       = ["Menghong Li"]
  spec.email         = ["menghong@redant.com.au"]
  spec.summary       = "API Request Logger"
  spec.description   = "Log Api Request using BigQuery and Redis"
  spec.homepage      = "https://github.com/Menghongli/api-request-logger"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency("google-api-client")
  spec.add_dependency("redis")
  spec.add_dependency("sidekiq")
  spec.add_dependency("sidekiq-middleware")
  spec.add_dependency("sidekiq-cron")

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rake-notes"
end
