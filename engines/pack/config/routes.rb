Pack::Engine.routes.draw do
  namespace :admin do
    root "packages#index"
    resources :accesses do
      member do
        post 'manage_access'
      end
    end
    resources :packages do
    	resources :versions
    end
    resources :versions
    resources :accesses
    resources :options_categories do
      member do
        get 'values'
      end
    end
  end
  root "packages#index"
  get "/docs/:page" => "docs#show"
  resources :versions, only: [:show,:index]
  resources :packages do
    collection do
      get 'json'
    end
    member do
      get 'show_new'
    end
  end
  resources :accesses,only: []  do
    collection do
      get 'form'
      post 'update'
      post 'update_accesses'
      post 'destroy'
      get 'load_for_versions'
    end

  end

end
