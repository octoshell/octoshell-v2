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

    resources :positions do
      member do
        get :api_logs
      end
    end

    resources :accesses do
      member do
        get :initial_edit
        patch :initial_update
        get :edit_vm
        patch :update_vm
        get :edit_links
        patch :update_links
        patch :approve
        patch :deny
        patch :reinstantiate
      end
      collection do
        post :create_from_request
      end
    end
    resources :nebula_identities do
      member do
        patch :change_state
        patch :vm_info
        get :api_logs
      end
    end
  end

  root 'items#index'
  resources :item_kinds
  resources :resource_kinds, only: :show

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
      get :edit_vm
      post :update_vm
      get :edit_links
      post :update_links

      post :to_sent
      post :cancel
    end
  end

  resources :nebula_identities do
    member do
      patch :change_state
      patch :vm_info
    end
  end

  resources :accesses do
    member do
      patch :finish
      patch :add_keys
    end
  end

end
