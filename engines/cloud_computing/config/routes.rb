CloudComputing::Engine.routes.draw do
  namespace :admin do
    root 'items#index'
    resources :resource_kinds
    resources :items
    resources :item_kinds do
      member do
        post :load_templates
        post :add_necessary_attributes

      end
      collection do
        get :edit_all
        get :jstree
      end
    end
    resources :resources
    resources :requests do
      member do
        patch :refuse
      end
    end
    resources :accesses do
      member do
        get :edit_links
        patch :update_links
        patch :pend
        patch :refuse
      end
      collection do
        post :create_from_request
      end
    end
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
      get :edit_created_request
      post :update_created_request
      post :to_sent
      post :cancel
    end
  end


end
