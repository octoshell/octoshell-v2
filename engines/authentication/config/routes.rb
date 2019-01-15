Authentication::Engine.routes.draw do
  get "users/activate/:token" => "users#activate", as: :activate_user
  resources :users, only: [:new, :create] do
    get :confirmation, on: :collection
  end

  resources :activations, only: [:new, :create]

  resource :session, only: [:new, :create, :destroy]
  get "/session" => "sessions#destroy"

  resource :password, only: [:new, :create]
  get "password/:token" => "passwords#change", as: :change_password

  root "sessions#new"
end
