Hardware::Engine.routes.draw do
  namespace :admin do
    root 'kinds#index'
    resources :kinds do
      collection do
        get :states
      end
      resources :states,except: :index
    end
    resources :items do
      collection do
        post :update_max_date
      end
      post :update_state
    end

  end
end
