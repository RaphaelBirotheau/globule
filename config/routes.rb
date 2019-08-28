Rails.application.routes.draw do
  devise_for :users

  resources :user_profiles, only: [:show, :new, :create]

  resources :orders, only: [:show]

  resources :products, only: [:show]

  resources :baskets, only:[:show]

  root to: 'pages#home'

  get "/my_profile", to: "users#profile"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
