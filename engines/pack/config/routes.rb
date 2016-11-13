Pack::Engine.routes.draw do
  resources :packages do
  	resources :versions 
  end
  resources  :versions, only: [:destroy]
  root "packages#index"
end
