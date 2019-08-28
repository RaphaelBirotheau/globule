Rails.application.routes.draw do
  devise_for :users

  resources :user_profiles, only: [:show, :new, :create]

  resources :orders, only: [:show]

  resources :products, only: [:show]

  root to: 'orders#last'

  get "/basket", to: "orders#recommended"

  get "/my_profile", to: "users#profile"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
