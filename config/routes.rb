Rails.application.routes.draw do
  devise_for :users

  resources :user_profiles, only: [:show, :new, :create]

  resources :orders, only: [:show]

  resources :products, only: [:show]

  resources :profiles, only: [:show]

  root to: 'orders#last'

  get "/recommandations", to: "orders#recommended"
  get "/lastbasket", to: "orders#last"
  get "/profile", to: "profiles#show"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
