class Frontkiq::DashboardController < Frontkiq::FrontkiqController

  def index
    stats_history = Sidekiq::Stats::History.new((params[:days] || 30).to_i)
    render locals: { redis_info:        redis_info.select { |k,v| REDIS_KEYS.include? k },
                     processed_history: stats_history.processed,
                     failed_history:    stats_history.failed }

  end

  private

  def redis_info
    Sidekiq.redis do |conn|
      conn.respond_to?(:namespace) ?
        conn.redis.info :
        conn.info
    end
  end
end
