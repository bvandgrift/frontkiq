source 'https://rubygems.org'
gemspec

gem 'rails', '~> 4.2'
gem 'haml'

group :test do
  gem 'simplecov'
  gem 'minitest'
  gem 'minitest-reporters'
  gem 'minitest-rails-capybara'
end

platforms :rbx do
  gem 'rubysl', '~> 2.0'         # if using anything in the ruby standard library
  gem 'psych'                    # if using yaml
  gem 'rubinius-developer_tools' # if using any of coverage, debugger, profiler
end

