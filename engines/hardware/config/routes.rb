Hardware::Engine.routes.draw do
  namespace :admin do
    root 'kinds#index'
    resources :items_states
    resources :kinds do
      collection do
        get :states
        get :index_json
      end
      resources :states, except: :index
    end
    resources :items do
      collection do
        post :update_max_date
        post :json_update
        get :index_json
      end
      post :update_state
    end

  end
end
