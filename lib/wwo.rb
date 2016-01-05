require "wwo/version"
require "wwo/configuration"

require 'hashie'
require 'multi_json'
require 'faraday'
require 'date'

module Wwo
  extend Configuration

  self.default_params = {}
  self.api_cache_store = nil

  class << self

    # Returns historic weather at the provided latitude and longitude coordinates, on a
    # specific date.
    #
    # @param latitude [String] Latitude.
    # @param longitude [String] Longitude.
    # @param date [Date] or [Integer] Date, or Unix Timestamp.
    #
    def historic(latitude, longitude, date_or_timestamp)
      date = date_or_timestamp.is_a?(Numeric) ? Time.at(date_or_timestamp).strftime("%F") : date_or_timestamp.strftime("%F")
      uri = "#{Wwo.api_endpoint}/past-weather.ashx?q=#{latitude},#{longitude}&date=#{date}&tp=24&format=json&key=#{Wwo.api_key}"

      api_response = get(uri)

      if api_response.success?
        return Hashie::Mash.new(MultiJson.load(api_response.body))
      end
    end

    # Returns historic weather at the provided latitude and longitude coordinates, on a
    # specific date.
    #
    # @param latitude [String] Latitude.
    # @param longitude [String] Longitude.
    # @param date [Date] or [Integer] Date, or Unix Timestamp.
    #
    def forecast(latitude, longitude, date_or_timestamp = Date.today)
      date = date_or_timestamp.is_a?(Numeric) ? Time.at(date_or_timestamp).strftime("%F") : date_or_timestamp.strftime("%F")
      uri = "#{Wwo.api_endpoint}/weather.ashx?q=#{latitude},#{longitude}&date=#{date}&num_of_days=1&tp=24&format=json&key=#{Wwo.api_key}"

      api_response = get(uri)

      if api_response.success?
        return Hashie::Mash.new(MultiJson.load(api_response.body))
      end
    end

    # Build or get an HTTP connection object.
    def connection
      return @connection if @connection
      @connection = Faraday.new
    end

    # Set an HTTP connection object.
    #
    # @param connection Connection object to be used.
    def connection=(connection)
      @connection = connection
    end

    private

    def get(path, params = {})
      params = Wwo.default_params.merge(params || {})

      connection.get(path, params)
    end
  end
end
