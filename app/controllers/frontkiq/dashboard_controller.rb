class Frontkiq::DashboardController < Frontkiq::FrontkiqController
  def index
    @redis_info = redis_info.select{ |k, v| REDIS_KEYS.include? k }
    stats_history = Sidekiq::Stats::History.new((params[:days] || 30).to_i)
    @processed_history = stats_history.processed
    @failed_history = stats_history.failed
  end
end
