Support::Engine.routes.draw do
  namespace :admin do
    resources :tickets, except: :destroy do
      put :close
      put :reopen
      post :accept
    end

    resources :replies, only: :create
    resources :reply_templates
    resources :topics
    resources :fields
    resources :tags, except: :destroy do
      put :merge
    end

    root "tickets#index"
  end

  resources :tickets, except: :destroy do
    post :continue, on: :collection
    put :close
    put :resolve
  end

  resources :replies, only: :create

  root "tickets#index"
end
