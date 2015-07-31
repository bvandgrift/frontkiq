require 'frontkiq/web'

Rails.application.routes.draw do

  mount Frontkiq::Web, at: '/frontkiq'

end
