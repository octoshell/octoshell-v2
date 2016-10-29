Wiki::Engine.routes.draw do
  resources :pages

  root "pages#index"
end
