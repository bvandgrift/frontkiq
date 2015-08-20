# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

# coverage?
if ENV["COVERAGE"]
  require 'simplecov'
  SimpleCov.start do
    add_filter "/test/"
  end
end

require File.expand_path('../../test/dummy/config/environment.rb',  __FILE__)
require 'rails/test_help'

require 'minitest/autorun'
#require 'minitest/pride'
require 'minitest/rails/capybara'

require "minitest/reporters"
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(fail_fast: true)]

# celluloud config
require 'celluloid/test'
Celluloid.boot

# sidekiq config
require 'sidekiq'
require 'sidekiq/util'
Sidekiq.logger.level = Logger::ERROR

Frontkiq::Test = Minitest::Test

# redis config
require 'sidekiq/redis_connection'
REDIS_URL = ENV['REDIS_URL'] || 'redis://localhost/15'
REDIS = Sidekiq::RedisConnection.create(:url => REDIS_URL, :namespace => 'testy')

Sidekiq.configure_client do |config|
  config.redis = { :url => REDIS_URL, :namespace => 'testy' }
end

# Filter out Minitest backtrace while allowing backtrace from other libraries
# to be shown.
Minitest.backtrace_filter = Minitest::BacktraceFilter.new

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)
  ActiveSupport::TestCase.fixtures :all
end
