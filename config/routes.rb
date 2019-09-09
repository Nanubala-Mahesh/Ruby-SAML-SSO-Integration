Rails.application.routes.draw do
  resources :products
  namespace :saml do
    get :init
    post :consume
    get :logout
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
