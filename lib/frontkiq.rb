# encoding: utf-8
require 'frontkiq/version'

require 'sidekiq/logging'
require 'sidekiq/client'
require 'sidekiq/worker'

require 'json'

module Frontkiq
  NAME = 'Frontkiq'
  LICENSE = 'See LICENSE and the LGPL-3.0 for licensing details.'

  DEFAULTS = {
  }

  def self.load_json(string)
    JSON.parse(string)
  end

  def self.dump_json(object)
    JSON.generate(object)
  end

  def self.logger
    Sidekiq::Logging.logger
  end

  def self.logger=(log)
    Sidekiq::Logging.logger = log
  end
end

require 'frontkiq/engine'
