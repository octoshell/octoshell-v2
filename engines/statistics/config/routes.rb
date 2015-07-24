Statistics::Engine.routes.draw do
  resources :users, only: :index do
    post :calculate_stats, on: :collection
  end

  resources :projects, only: :index do
    post :calculate_stats, on: :collection
  end

  resources :organizations, only: :index do
    post :calculate_stats, on: :collection
  end

  resources :sessions, only: :index do
    post :calculate_stats, on: :collection
  end
end
