CloudComputing::Engine.routes.draw do
  namespace :admin do
    root 'clusters#index'
    resources :clusters
    resources :resource_kinds
    resources :configurations
    resources :resources
  end
  root 'requests#index'
  resources :requests

end
