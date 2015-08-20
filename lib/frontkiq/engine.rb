module Frontkiq
  class Engine < ::Rails::Engine
    initializer :add_view_paths do
      views = paths["app/views"].existent
      puts "**** view paths"
      puts views.inspect
      unless views.empty?
        ActiveSupport.on_load(:action_controller){ prepend_view_path(views) }
        ActiveSupport.on_load(:action_mailer){ prepend_view_path(views) }
      end
    end
  end
end
