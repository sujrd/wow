require 'spec_helper'

context "The WWO Online Free API" do

  it "Correctly selects the Free API when asked" do
    expect(Wwo.use_premium_api).to_not eq(true)
  end

  # Use Tokyo for the weather location
  #
  let(:latitude) { "35.689488" }
  let(:longitude) { "139.691706" }

  context "Forecast.io Backwards Compatibility" do

    before :each do
       Wwo.api_key = "your-api-key"
     end

    it "exposes a forecast method" do
      expect(Wwo.respond_to?(:forecast)).to eq(true)
    end

    it "returns a non-empty response for a valid request in the past" do
      time = Time.utc(2016,1,1,0).to_i
      expect(Wwo.api_key).to_not be_nil

      VCR.use_cassette("forecast_for_tokyo_on_jan_1st_2016") do
        weather = Wwo.forecast(latitude, longitude, time: time)
        expect(weather.inspect).to_not be_empty
      end
    end

    it "returns a response in the expected format for a request in the past" do
      time = Time.utc(2016,1,1,0).to_i
      expect(Wwo.api_key).to_not be_nil

      VCR.use_cassette("forecast_for_tokyo_on_jan_1st_2016") do
        weather = Wwo.forecast(latitude, longitude, time: time)

        expect(weather.daily.data.size).to eq(1)
        expect(weather.alerts).to be_nil

        daily = weather.daily.data[0]

        expect(daily.icon).to eq("http://cdn.worldweatheronline.net/images/wsymbols01_png_64/wsymbol_0001_sunny.png")
        expect(daily.temperatureMax).to eq("15")
        expect(daily.temperatureMin).to eq("4")
      end
    end

  end

end