module Wwo
  module Configuration
    # Default API endpoint
    DEFAULT_FREE_ENDPOINT       = 'https://api.worldweatheronline.com/free/v2/'
    DEFAULT_PREMIUM_ENDPOINT    = 'https://api.worldweatheronline.com/premium/v1/'

    # Forecast API endpoint
    attr_writer :api_endpoint

    # API key
    attr_writer :api_key

    # Cache Object
    attr_writer :api_cache_store

    # Cache Object
    attr_writer :use_premium_api

    # Default parameters
    attr_accessor :default_params

    # Example:
    #
    #   Wwo.configure do |configuration|
    #     configuration.use_peremium_api = true
    #     configuration.api_key = 'this-is-your-api-key'
    #   end
    def configure
      yield self
    end

    # API endpoint
    def api_endpoint
      @api_endpoint ||= ( use_premium_api? ? DEFAULT_PREMIUM_ENDPOINT : DEFAULT_FREE_ENDPOINT )
    end

    # API key
    def api_key
      @api_key
    end

    def use_premium_api
      @use_premium_api
    end

    # API Cache Object
    def api_cache_store
      @api_cache_store
    end

    private

    def use_premium_api?
      @use_premium_api == true
    end
  end
end
