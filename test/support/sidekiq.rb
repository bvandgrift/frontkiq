# encoding: utf-8

require 'frontkiq'

class WebWorker
  include Sidekiq::Worker

  def perform(a, b)
    a + b
  end
end


def job_params(job, score)
  "#{score}-#{job['jid']}"
end

#before do
#  Sidekiq.redis = REDIS
#  Sidekiq.redis {|c| c.flushdb }
#end

def add_scheduled
  score = Time.now.to_f
  msg = { 'class' => 'HardWorker',
          'args' => ['bob', 1, Time.now.to_f],
          'jid' => SecureRandom.hex(12) }
  Sidekiq.redis do |conn|
    conn.zadd('schedule', score, Sidekiq.dump_json(msg))
  end
  [msg, score]
end

def add_retry
  msg = { 'class' => 'HardWorker',
          'args' => ['bob', 1, Time.now.to_f],
          'queue' => 'default',
          'error_message' => 'Some fake message',
          'error_class' => 'RuntimeError',
          'retry_count' => 0,
          'failed_at' => Time.now.to_f,
          'jid' => SecureRandom.hex(12) }
  score = Time.now.to_f
  Sidekiq.redis do |conn|
    conn.zadd('retry', score, Sidekiq.dump_json(msg))
  end
  [msg, score]
end

def add_dead
  msg = { 'class' => 'HardWorker',
          'args' => ['bob', 1, Time.now.to_f],
          'queue' => 'foo',
          'error_message' => 'Some fake message',
          'error_class' => 'RuntimeError',
          'retry_count' => 0,
          'failed_at' => Time.now.utc,
          'jid' => SecureRandom.hex(12) }
  score = Time.now.to_f
  Sidekiq.redis do |conn|
    conn.zadd('dead', score, Sidekiq.dump_json(msg))
  end
  [msg, score]
end

def add_xss_retry
  msg = { 'class' => 'FailWorker',
          'args' => ['<a>hello</a>'],
          'queue' => 'foo',
          'error_message' => 'fail message: <a>hello</a>',
          'error_class' => 'RuntimeError',
          'retry_count' => 0,
          'failed_at' => Time.now.to_f,
          'jid' => SecureRandom.hex(12) }
  score = Time.now.to_f
  Sidekiq.redis do |conn|
    conn.zadd('retry', score, Sidekiq.dump_json(msg))
  end
  [msg, score]
end

def add_worker
  key = "#{hostname}:#{$$}"
  msg = "{\"queue\":\"default\",\"payload\":{\"retry\":true,\"queue\":\"default\",\"timeout\":20,\"backtrace\":5,\"class\":\"HardWorker\",\"args\":[\"bob\",10,5],\"jid\":\"2b5ad2b016f5e063a1c62872\"},\"run_at\":1361208995}"
  Sidekiq.redis do |conn|
    conn.multi do
      conn.sadd("processes", key)
      conn.hmset(key, 'info', Sidekiq.dump_json('hostname' => 'foo', 'started_at' => Time.now.to_f, "queues" => []), 'at', Time.now.to_f, 'busy', 4)
      conn.hmset("#{key}:workers", Time.now.to_f, msg)
    end
  end
end
