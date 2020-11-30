CloudComputing::Engine.routes.draw do
  namespace :admin do
    root 'clusters#index'
    resources :clusters
    resources :resource_kinds
    resources :items
    resources :item_kinds do
      collection do
        get :edit_all
        get :jstree
      end
    end
    resources :resources
  end
  root 'items#index'
  resources :item_kinds
  resources :items do
    member do
      post :update_position
      get :simple_show
    end
  end
  resources :requests do
    collection do
      get :created_request
    end
  end


end
