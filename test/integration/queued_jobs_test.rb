# encoding: utf-8
require 'test_helper'
require 'frontkiq'

class QueuedJobsTest < Frontkiq::Test
  ROUTE = '/frontkiq/queued_jobs'.freeze

  describe ROUTE do
    include Rack::Test::Methods

    def app
      Dummy::Application 
    end

    before do
      Sidekiq.redis = REDIS
      Sidekiq.redis { |c| c.flushdb }
    end

    it 'can display queues' do
      skip("feature!")
      assert Sidekiq::Client.push('queue' => :foo, 'class' => WebWorker, 'args' => [1, 3])

      get ROUTE
      assert_equal 200, last_response.status
      assert_match(/foo/, last_response.body)
      refute_match(/HardWorker/, last_response.body)
    end

    it 'handles queue view' do
      skip("feature!")
      get '/queues/default'
      assert_equal 200, last_response.status
    end

    it 'can delete a queue' do
      Sidekiq.redis do |conn|
        conn.rpush('queue:foo', '{}')
        conn.sadd('queues', 'foo')
      end

      get "#{ROUTE}/foo"
      assert_equal 200, last_response.status

      post "#{ROUTE}/foo"
      assert_equal 302, last_response.status

      Sidekiq.redis do |conn|
        refute conn.smembers('queues').include?('foo')
        refute conn.exists('queue:foo')
      end
    end

    it 'can delete a job' do
      Sidekiq.redis do |conn|
        conn.rpush('queue:foo', "{}")
        conn.rpush('queue:foo', "{\"foo\":\"bar\"}")
        conn.rpush('queue:foo', "{\"foo2\":\"bar2\"}")
      end

      get "#{ROUTE}/foo"
      assert_equal 200, last_response.status

      post "#{ROUTE}/foo/delete", key_val: "{\"foo\":\"bar\"}"
      assert_equal 302, last_response.status

      Sidekiq.redis do |conn|
        refute conn.lrange('queue:foo', 0, -1).include?("{\"foo\":\"bar\"}")
      end
    end
  end
end
