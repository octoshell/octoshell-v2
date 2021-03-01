CloudComputing::Engine.routes.draw do
  namespace :admin do
    root 'templates#index'
    resources :resource_kinds
    resources :templates
    resources :template_kinds do
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

    resources :items do
      member do
        get :api_logs
      end
    end

    resources :accesses do
      member do
        patch :approve
        patch :deny
        patch :finish
        patch :reinstantiate
        patch :prepare_to_deny
      end
      collection do
        post :create_from_request
      end
    end
    resources :virtual_machines do
      member do
        patch :change_state
        patch :vm_info
        get :api_logs
      end
    end
  end

  root 'templates#index'
  resources :template_kinds
  resources :resource_kinds, only: :show

  resources :templates do
    member do
      post :update_position
      get :simple_show
    end
  end
  resources :requests do
    collection do
      put :add_item_from_access
      get :created_request
      get :edit_created_request
      post :update_created_request
      post :to_sent
      post :cancel
    end
  end

  resources :virtual_machines do
    member do
      patch :change_state
      patch :vm_info
    end
  end

  resources :accesses do
    member do
      patch :add_keys
      patch :prepare_to_finish
    end
  end

end
