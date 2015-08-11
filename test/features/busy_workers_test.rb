# encoding: utf-8
require 'test_helper'
require 'frontkiq'
require 'sidekiq/api'

# setup

feature "/busy_workers" do

  before(:each) do
    Sidekiq.redis = REDIS
    Sidekiq.redis {|c| c.flushdb }
  end

  scenario "loads" do
    visit frontkiq_busy_workers_path # frontkiq_dashboard_path
    page.must_have_content "Busy Workers"
  end

  scenario "displays workers" do
    Sidekiq.redis do |conn|
      conn.incr('busy')
      conn.sadd('processes', 'foo:1234')
      conn.hmset('foo:1234', 'info', Sidekiq.dump_json('hostname' => 'foo', 'started_at' => Time.now.to_f, "queues" => []), 'at', Time.now.to_f, 'busy', 4)
      identity = 'foo:1234:workers'
      hash = {:queue => 'critical', :payload => { 'class' => WebWorker.name, 'args' => [1,'abc'] }, :run_at => Time.now.to_i }
      conn.hmset(identity, 1001, Sidekiq.dump_json(hash))
    end
    assert_equal ['1001'], Sidekiq::Workers.new.map { |pid, tid, data| tid }

    visit frontkiq_busy_workers_path
    assert_equal 200, page.status_code

    page.must_have_css 'i.status-active'
    page.must_have_content 'critical'
    page.must_have_content 'WebWorker'
  end
end
