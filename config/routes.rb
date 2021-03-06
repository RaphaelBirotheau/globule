Rails.application.routes.draw do
  devise_for :users

  resources :user_profiles, only: [:show, :new, :create]



  resources :orders, only: [:show, :new, :create] do
    member do
      get 'recommendations'
    end
  end


  resources :products, only: [:show]

  resources :profiles, only: [:show]

  root to: 'pages#home'

  # get "/recommandations", to: "orders#recommended"
  get "/lastbasket", to: "orders#last"
  get "/profile", to: "profiles#show"
  get "/dashboard", to: "profiles#dashboard"
  get "/orders", to: "orders#index"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
