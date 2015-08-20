# encoding: utf-8
require 'test_helper'
require 'frontkiq'

class PendingRetriesTest < Frontkiq::Test
  ROUTE = '/frontkiq/pending_retries'.freeze

  describe ROUTE do
    include Rack::Test::Methods

    def app
      Dummy::Application 
    end

    def job_params(job, score)
      "#{score}-#{job['jid']}"
    end

    it 'displays retries' do
      get ROUTE
      assert_equal 200, last_response.status
      assert_match(/found/, last_response.body)
      refute_match(/HardWorker/, last_response.body)

      add_retry

      get ROUTE
      assert_equal 200, last_response.status
      refute_match(/found/, last_response.body)
      assert_match(/HardWorker/, last_response.body)
    end

    it 'can display a single retry' do
      skip("next!")
      params = add_retry
      get "#{ROUTE}/#{job_params(*params)}"
      assert_equal 200, last_response.status
      assert_match(/HardWorker/, last_response.body)
    end

    it 'handles missing retry' do
      skip("next!")
      get "#{ROUTE}/0-shouldntexist"
      assert_equal 302, last_response.status
    end

    it 'can delete a single retry' do
      skip("next!")
      params = add_retry
      post "#{ROUTE}/#{job_params(*params)}/delete"
      assert_equal 302, last_response.status
      assert_equal "http://example.org#{ROUTE}", last_response.header['Location']

      get ROUTE 
      assert_equal 200, last_response.status
      refute_match(/#{params.first['args'][2]}/, last_response.body)
    end

    it 'can delete all retries' do
      skip("next!")
      3.times { add_retry }

      post "#{ROUTE}/delete_all", 'delete' => 'Delete'
      assert_equal 0, Sidekiq::RetrySet.new.size
      assert_equal 302, last_response.status
      assert_equal "http://example.org#{ROUTE}", last_response.header['Location']
    end

    it 'can retry a single retry now' do
      params = add_retry
      jid = params.first['jid']
      score = params.second

      post "#{ROUTE}/#{jid}/retry", score: score
      assert_equal 302, last_response.status
      assert_equal "http://example.org#{ROUTE}", last_response.header['Location']

      get '/queues/default'
      assert_equal 200, last_response.status
      assert_match(/#{params.first['args'][2]}/, last_response.body)
    end

    it 'can kill a single retry now' do
      params = add_retry
      jid = params.first['jid']
      score = params.second

      post "#{ROUTE}/#{jid}/kill", score: score
      assert_equal 302, last_response.status
      assert_equal "http://example.org#{ROUTE}", last_response.header['Location']

      skip("fix when abandoned jobs is done.")
      get '/abandoned_jobs'
      assert_equal 200, last_response.status
      assert_match(/#{params.first['args'][2]}/, last_response.body)
    end

    it 'can retry all retries' do
      skip("next!")
      msg = add_retry.first
      add_retry

      post "#{ROUTE}/retry_all", 'retry' => 'Retry'
      assert_equal 302, last_response.status
      assert_equal 'http://example.org#{ROUTE}', last_response.header['Location']
      assert_equal 2, Sidekiq::Queue.new("default").size

      get '/queued_jobs/default'
      assert_equal 200, last_response.status
      assert_match(/#{msg['args'][2]}/, last_response.body)
    end

    it 'escape job args and error messages' do
      skip("integrated feature!")
      # on /retries page
      params = add_xss_retry
      get "#{ROUTE}"
      assert_equal 200, last_response.status
      assert_match(/FailWorker/, last_response.body)

      assert last_response.body.include?( "fail message: &lt;a&gt;hello&lt;&#x2F;a&gt;" )
      assert !last_response.body.include?( "fail message: <a>hello</a>" )

      assert last_response.body.include?( "args\">&quot;&lt;a&gt;hello&lt;&#x2F;a&gt;&quot;<" )
      assert !last_response.body.include?( "args\"><a>hello</a><" )

      # on /workers page
      Sidekiq.redis do |conn|
        pro = 'foo:1234'
        conn.sadd('processes', pro)
        conn.hmset(pro, 'info', Sidekiq.dump_json('started_at' => Time.now.to_f, 'labels' => ['frumduz'], 'queues' =>[]), 'busy', 1, 'beat', Time.now.to_f)
        identity = "#{pro}:workers"
        hash = {:queue => 'critical', :payload => { 'class' => "FailWorker", 'args' => ["<a>hello</a>"] }, :run_at => Time.now.to_i }
        conn.hmset(identity, 100001, Sidekiq.dump_json(hash))
        conn.incr('busy')
      end

      get '/busy'
      assert_equal 200, last_response.status
      assert_match(/FailWorker/, last_response.body)
      assert_match(/frumduz/, last_response.body)
      assert last_response.body.include?( "&lt;a&gt;hello&lt;&#x2F;a&gt;" )
      assert !last_response.body.include?( "<a>hello</a>" )


      # on /queues page
      params = add_xss_retry # sorry, don't know how to easily make this show up on queues page otherwise.
      post "#{ROUTE}/#{job_params(*params)}", 'retry' => 'Retry'
      assert_equal 302, last_response.status

      get '/queues/foo'
      assert_equal 200, last_response.status
      assert last_response.body.include?( "&lt;a&gt;hello&lt;&#x2F;a&gt;" )
      assert !last_response.body.include?( "<a>hello</a>" )
    end
  end
end
