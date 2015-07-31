module Frontkiq
  def self.hook_rails!
    # Placeholder
  end

  class Rails < ::Rails::Engine
    initializer 'frontkiq.rails_hooks' do |app|
      Frontkiq.hook_rails!
    end

    initializer 'frontkiq' do |app|
      app.config.assets.paths << File.join(File.expand("../../..", __FILE__), "web", "assets")
      app.config.assets.precompile += %w(bootstrap.css jquery*.js dashboard.js)
    end
  end if defined?(::Rails)
end
