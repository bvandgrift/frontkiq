# encoding: utf-8
require 'test_helper'
require 'frontkiq'

class BusyWorkersTest < Frontkiq::Test

  describe '/busy_workers' do
    include Rack::Test::Methods

    def app
      Dummy::Application 
    end

    before do
      Sidekiq.redis = REDIS
      Sidekiq.redis { |c| c.flushdb }
    end

    it 'can quiet a process' do
      identity = 'identity'
      signals_key = "#{identity}-signals"

      assert_nil Sidekiq.redis { |c| c.lpop signals_key }
      post '/frontkiq/busy_workers', { quiet: 1, identity: identity }

      assert_equal 302, last_response.status
      assert_equal 'USR1', Sidekiq.redis { |c| c.lpop signals_key }
    end

    it 'can stop a process' do
      identity = 'identity'
      signals_key = "#{identity}-signals"

      assert_nil Sidekiq.redis { |c| c.lpop signals_key }
      post '/frontkiq/busy_workers', { stop: 1, identity: identity }

      assert_equal 302, last_response.status
      assert_equal 'TERM', Sidekiq.redis { |c| c.lpop signals_key }
    end

    it 'calls updatePage() once when polling' do
      get '/frontkiq/busy_workers', { poll: true }

      assert_equal 200, last_response.status
      assert_equal 1, last_response.body.scan('updatePage(').count
    end
  end

end
