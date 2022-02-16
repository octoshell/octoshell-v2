Perf::Engine.routes.draw do
  root "main#index"

  resources :main do
    collection do
      get :research_areas
      get :experienced_users
      get :packages
    end
  end

  namespace :admin do
    resources :experts do
      
    end
  end

end
