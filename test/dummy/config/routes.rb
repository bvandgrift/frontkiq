Rails.application.routes.draw do
  mount Frontkiq::Engine => '/frontkiq'
end
