Wikiplus::Engine.routes.draw do
  resources :pages
  namespace :admin do
    resources :pages
    resources :images

    resources :pages do
      member do
        post :createsubpage
        get :newsubpage
      end
    end
  end

  root "pages#index"
end
