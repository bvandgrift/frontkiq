Rails.application.routes.draw do
  # ladies and gentlemen, @adamhunter!
  root to: ->(_) { [200, {}, ['Werd']] }
end
