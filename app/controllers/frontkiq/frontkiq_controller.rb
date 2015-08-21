require 'sidekiq'
require 'sidekiq/api'
require 'sidekiq/paginator'
# require 'sidekiq/web_helpers'

class Frontkiq::FrontkiqController < ApplicationController
  include Sidekiq::Paginator

  layout 'frontkiq'

  REDIS_KEYS = %w(redis_version uptime_in_days connected_clients used_memory_human used_memory_peak_human)

  protected

  helper_method :parse_key
  def parse_key(params)
    score, jid = params.split("-")
    [score.to_f, jid]
  end
end
