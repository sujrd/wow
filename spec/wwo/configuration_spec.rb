require 'spec_helper'

describe Wwo::Configuration do

  context 'Default API Endpoints' do
    it 'has the expected premium endpoint by default' do
      expect(Wwo::Configuration::DEFAULT_PREMIUM_ENDPOINT).to eql('https://api.worldweatheronline.com/premium/v1')
    end

    it 'has the expected free endpoint by default' do
      expect(Wwo::Configuration::DEFAULT_FREE_ENDPOINT).to eql('https://api.worldweatheronline.com/free/v2')
    end
  end

  context 'The Configuration::configure method' do

    it 'defaults to no API Key and the free endpoint' do
      Wwo.configure do |configuration|
        expect(configuration.api_endpoint).to eql(Wwo::Configuration::DEFAULT_FREE_ENDPOINT)
        expect(configuration.api_key).to be_nil
      end
    end

    it 'uses the premium endpoint when that is set' do
      Wwo.configure do |configuration|
        expect(configuration.api_endpoint).to eql(Wwo::Configuration::DEFAULT_FREE_ENDPOINT)
        configuration.use_premium_api = true
        expect(configuration.use_premium_api).to eql(true)
        expect(configuration.api_endpoint).to eql(Wwo::Configuration::DEFAULT_PREMIUM_ENDPOINT)
      end
    end

    it 'always uses the endpoint which you set' do
      Wwo.configure do |configuration|
        configuration.api_endpoint = 'http://www.google.com'
      end

      expect(Wwo.api_endpoint).to eql('http://www.google.com')

      Wwo.configure do |configuration|
        configuration.api_endpoint = nil
      end
    end

  end

end
