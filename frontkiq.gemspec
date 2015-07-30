# -*- encoding: utf-8 -*-
require File.expand_path('../lib/frontkiq/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Ben Vandgrift"]
  gem.email         = ["ben@vandgrift.com"]
  gem.summary       = "A front-end sinatra app for sidekiq with Rails asset host support."
  gem.description   = "A front-end sinatra app for sidekiq with Rails asset host support."
  gem.homepage      = "http://github.com/tma1/frontkiq"
  gem.license       = "LGPL-3.0"

  gem.files         = `git ls-files | grep -Ev '^(myapp|examples)'`.split("\n")
  gem.test_files    = `git ls-files -- test/*`.split("\n")
  gem.name          = "frontkiq"
  gem.require_paths = ["lib"]
  gem.version       = Frontkiq::VERSION
  gem.add_dependency                  'sidekiq', '~> 3.4', '>= 3.4.2'
  gem.add_development_dependency      'sinatra', '~> 1.4', '>= 1.4.6'
  gem.add_development_dependency      'minitest', '~> 5.7', '>= 5.7.0'
  gem.add_development_dependency      'rake', '~> 10.0'
  gem.add_development_dependency      'rails', '~> 4', '>= 3.2.0'
end
