$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'rspec'
require 'wwo'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

require 'vcr'
require 'typhoeus/adapters/faraday'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :typhoeus
  c.allow_http_connections_when_no_cassette = false
end

Faraday.default_adapter = :typhoeus

require "codeclimate-test-reporter"
CodeClimate::TestReporter.start


=begin
RSpec.configure do |config|
  config.before(:each) do
    Wwo.api_key = nil
  end
end
=end
