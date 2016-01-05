require "wwo/version"
require "wwo/configuration"

require 'hashie'
require 'multi_json'
require 'faraday'

module Wwo
  extend Configuration

  self.default_params = {}
  self.api_cache_store = nil
end
