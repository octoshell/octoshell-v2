Pack::Engine.routes.draw do
  resources :packages
  root "packages#index"
end
