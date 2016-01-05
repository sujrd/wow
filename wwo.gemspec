# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wwo/version'

Gem::Specification.new do |spec|
  spec.name          = "wwo"
  spec.version       = Wwo::VERSION
  spec.authors       = ["株式会社アルム　Allm Inc", "Ryan Stenhouse", "David Czarnecki"]
  spec.email         = ["r.stenhouse@allm.net"]

  spec.summary       = %q{Rubygem for accessing the free and premium weather APIs from World Weather Online.  Inspired by Dark Sky's Forecast.IO gem.}
  spec.homepage      = "https://github.com/sujrd/wwo"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]


  spec.add_dependency('faraday')
  spec.add_dependency('faraday-http-cache')
  spec.add_dependency('multi_json')
  spec.add_dependency('hashie')

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency('vcr')
  spec.add_development_dependency('typhoeus')
end
