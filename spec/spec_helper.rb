$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'simplecov'
require "codeclimate-test-reporter"
require 'rspec'
require 'wwo'
require 'vcr'
require 'typhoeus/adapters/faraday'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :typhoeus
  c.allow_http_connections_when_no_cassette = false
end

Faraday.default_adapter = :typhoeus

RSpec.configure do |config|
  config.before(:each) do
    Wwo.api_key = nil
    Wwo.use_premium_api = false
  end
end

SimpleCov.start
CodeClimate::TestReporter.start

