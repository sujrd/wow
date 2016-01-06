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

    # Provides API compatibility to forecast.io's rubygem - expects the same signature and a
    # Unix Timestamp for :time, it will use the historic / now_or_later methods under the hood
    # to actually do its work.
    #
    def forecast(latitude, longitude, options = {})
      if options[:time]
        date = Time.at(options[:time])
      else
        date = Time.now
      end

      if date.to_i < Time.now.to_i
        make_into_forecast_response(historic(latitude, longitude, date))
      else
        make_into_forecast_response(now_or_later(latitude, longitude, date))
      end
    end

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
      api_call(uri)
    end

    # Returns historic weather at the provided latitude and longitude coordinates, on a
    # specific date.
    #
    # @param latitude [String] Latitude.
    # @param longitude [String] Longitude.
    # @param date [Date] or [Integer] Date, or Unix Timestamp.
    #
    def now_or_later(latitude, longitude, date_or_timestamp = Date.today)
      date = date_or_timestamp.is_a?(Numeric) ? Time.at(date_or_timestamp).strftime("%F") : date_or_timestamp.strftime("%F")
      uri = "#{Wwo.api_endpoint}/weather.ashx?q=#{latitude},#{longitude}&date=#{date}&num_of_days=1&tp=24&format=json&key=#{Wwo.api_key}"
      api_call(uri)
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

    def api_call(uri)
      api_response = get(uri)
      if api_response.success?
        return Hashie::Mash.new(MultiJson.load(api_response.body))
      else
        return {}
      end
    end

    def get(path, params = {})
      params = Wwo.default_params.merge(params || {})
      connection.get(path, params)
    end

    # Munges the repsonse into one like what we would expect from Forecast.io
    #
    def make_into_forecast_response(response)
      data = { daily: { data: [ { icon: '', 'temperatureMax' => 0, 'temperatureMin' => 0  } ] }, alerts: nil }
      data[:daily][:data][0][:icon] = response.data.weather.first.hourly.first.weatherIconUrl.first.value
      data[:daily][:data][0]['temperatureMax'] = response.data.weather.first.maxtempC
      data[:daily][:data][0]['temperatureMin'] = response.data.weather.first.mintempC
      Hashie::Mash.new(data)
    end
  end
end
