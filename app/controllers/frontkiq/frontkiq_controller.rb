require 'sidekiq'
require 'sidekiq/api'
require 'sidekiq/paginator'
require 'sidekiq/web_helpers'

class Frontkiq::FrontkiqController < ApplicationController
  include Sidekiq::Paginator

  layout :frontkiq

end
