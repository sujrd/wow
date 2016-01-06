# WWO - World Weather Online API Gem

[![Gem Version](https://badge.fury.io/rb/wwo.svg)](https://badge.fury.io/rb/wwo) [![Build Status](https://travis-ci.org/sujrd/wwo.svg?branch=master)](https://travis-ci.org/sujrd/wwo) [![Join the chat at https://gitter.im/sujrd/wwo](https://badges.gitter.im/sujrd/wwo.svg)](https://gitter.im/sujrd/wwo?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge) [![Code Climate](https://codeclimate.com/github/sujrd/wwo/badges/gpa.svg)](https://codeclimate.com/github/sujrd/wwo) [![Test Coverage](https://codeclimate.com/github/sujrd/wwo/badges/coverage.svg)](https://codeclimate.com/github/sujrd/wwo/coverage)

This gem provides a (for now) very opinionated interface to [World Weather Online's API][1]. It's based heavily on the
[forecast-ruby gem](https://github.com/darkskyapp/forecast-ruby) by the wonderful people over at Dark Skies / Forecast.io
and was bourne out of the need to have a drop in replacemnet for Forecast.io in an application.

The plan is to enhance this over time so that it supports more of WWO's API and is a bit more developer friendly. Right now,
however, there are the following assumptions / options that you need to be aware of:

  * Temperatures are always returned in **degrees celcius**.
  * For now we only expect requests for one day at a time, as per the way forecast-ruby works
  * We only pull in **daily snapshot** information, that is, the predomanant weather over the 24h period of the day in question.
  * We futz around with the response back, so it is in the same shape of JSON as you get back from `forecast.io`. This is intentional -
    remember that we intend this to be (for now), a drop-in replacement for forecast.io.

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