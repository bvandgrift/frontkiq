class Frontkiq::SidekiqDecorator
  def current_status
    workers.size == 0 ? 'idle' : 'active'
  end

  def workers
    @workers ||= Sidekiq::Workers.new
  end

  def processes
    @processes ||= Sidekiq::ProcessSet.new
  end

  def stats
    @stats ||= Sidekiq::Stats.new
  end

  def redis_connection
    @redis_client_id ||= Sidekiq.redis { |conn| conn.client.id }
  end

  def namespace
    @ns ||= Sidekiq.redis { |conn| conn.namespace if conn.respond_to?(:namespace) }
  end

end
