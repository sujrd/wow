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

    # Returns a daily breakdown for weather for the provided start and end data at the
    # specified location.
    #
    def date_range(start_date, end_date, latitude, longitude, forecast_compat = false)
      start_date_string = start_date.strftime('%F')
      end_date_string   = end_date.strftime('%F')
      today_date_string = Time.now.strftime('%F')

      if start_date_string == today_date_string || range_in_future?(start_date, end_date)
        uri = "#{Wwo.api_endpoint}/weather.ashx?q=#{latitude},#{longitude}&format=json&num_of_days=7&date=today&cc=no&mca=no&tp=24&key=#{Wwo.api_key}"
        response = Hashie::Mash.new(api_call(uri))
        if forecast_compat
          return make_into_forecast_response(response)
        else
          return response
        end

      elsif starts_in_past_but_ends_in_future?(start_date, end_date)
        yesterday_date_string = (Time.now - (24 *(60 * 60))).strftime('%F')

        uri = "#{Wwo.api_endpoint}/past-weather.ashx?q=#{latitude},#{longitude}&format=json&extra=utcDateTime&date=#{start_date_string}&enddate=#{yesterday_date_string}&show_comments=no&tp=24&key=#{Wwo.api_key}&mca=false&show_comments=false"
        past_response = Hashie::Mash.new(api_call(uri))
        uri = "#{Wwo.api_endpoint}/weather.ashx?q=#{latitude},#{longitude}&format=json&num_of_days=7&date=today&cc=no&mca=no&tp=24&key=#{Wwo.api_key}"
        future_response = Hashie::Mash.new(api_call(uri))

        if forecast_compat
          past    = make_into_forecast_response(past_response)
          future  = make_into_forecast_response(future_response)
          past[:daily][:data] = (past[:daily][:data] + future[:daily][:data]).flatten.uniq

          return past
        else
          return past_response.deep_merge(future_response)
        end

      else
        uri = "#{Wwo.api_endpoint}/past-weather.ashx?q=#{latitude},#{longitude}&format=json&extra=utcDateTime&date=#{start_date_string}&enddate=#{end_date_string}&show_comments=no&tp=24&key=#{Wwo.api_key}&mca=false&show_comments=false"
        response = Hashie::Mash.new(api_call(uri))
        if forecast_compat
          return make_into_forecast_response(response)
        else
          return response
        end
      end
    end

    def starts_in_past_but_ends_in_future?(start_date, end_date)
      start_date.to_i < Time.now.to_i && end_date.to_i >= Time.now.to_i
    end

    def range_in_future?(start_date, end_date)
      end_date.to_i >= Time.now.to_i && start_date.to_i >= Time.now.to_i
    end

    # Returns an hourly breakdown for the weather "today" at the given location. We get
    # the current time and then turn it into UTC. Returns a Hashie Mash with every hour of
    # weather broken down.
    #
    def today(latitude, longitude)
      date = Time.now.utc.strftime("%F")
      uri = "#{Wwo.api_endpoint}/weather.ashx?q=#{latitude},#{longitude}&date=today&num_of_days=1&tp=1&format=json&key=#{Wwo.api_key}&mca=false&show_comments=false"
      api_call(uri)
    end

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
      if response.is_a?(Hash) && response.empty?
        return { daily: { data: [] } }
      elsif ! response.data.weather.nil? && response.data.weather.any? && response.data.weather.size > 1
        data = { daily: { data: [] } }
        response.data.weather.each do |weather|
          icon = weather.hourly.first.weatherIconUrl.first.value
          maxTemp = weather.maxtempC
          minTemp = weather.mintempC
          date = Time.parse("#{weather.date} 12:00:00")

          data[:daily][:data] << { icon: icon, "temperatureMax" => maxTemp, "temperatureMin" => minTemp, date: date }
        end
        return data
      else
        data = { daily: { data: [ { icon: '', 'temperatureMax' => 0, 'temperatureMin' => 0  } ] }, alerts: nil }
        data[:daily][:data][0][:icon] = response.data.weather.first.hourly.first.weatherIconUrl.first.value
        data[:daily][:data][0]['temperatureMax'] = response.data.weather.first.maxtempC
        data[:daily][:data][0]['temperatureMin'] = response.data.weather.first.mintempC
        return data
      end
    end
  end
end
