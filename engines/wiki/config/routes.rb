Wiki::Engine.routes.draw do
  resources :tasks
  resources :pages

  root "pages#index"
end
