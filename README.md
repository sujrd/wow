# WWO - World Weather Online API Gem

This gem provides a (for now) very opinionated interface to [World Weather Online's API][1]. It's based heavily on the
[forecast-ruby gem](https://github.com/darkskyapp/forecast-ruby) by the wonderful people over at Dark Skies / Forecast.io
and was bourne out of the need to have a drop in replacemnet for Forecast.io in an application.

The plan is to ehance this over time so that it supports more of WWO's API. Right now it supports forecasts and historical
weather for a lat / long pair of anywhere in the world.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'wwo'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install wwo

## Usage


Basic usage is just like the forecast gem. For example, if you were calling the API from a
Rails action, you might want to do this:

````ruby
Wwo.configure do |configuration|
  configuration.api_key = 'this-is-your-api-key'
  configuration.use_premium_api = true # default is false
end

Wwo.connection = Faraday.new do |builder|
   builder.use Faraday::HttpCache, store: Rails.cache, serializer: Marshal
   builder.adapter Faraday.default_adapter
end

weather = Wwo.forecast(latitude, longitude, time: timestamp)
````

The `forecast` method provides API compatibilty with `forecast-ruby`. We also expose `historic` for any
past weather and `now_or_future` for any forecasting that is required.

We also play around with the response we get back from WWO so that it is in the same structure as the response
from the Dark Sky API. The main difference is that the icon names will be the actual URLs to icon images served
from WWO's CDN.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sujrd/wwo. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).


[1]: https://developer.worldweatheronline.com