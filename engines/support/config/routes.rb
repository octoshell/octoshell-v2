Support::Engine.routes.draw do
  namespace :admin do
    resources :tickets, except: :destroy do
      put :close
      put :reopen
      post :accept
      member do
        put :edit_responsible
      end
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
    put :reopen
  end

  get 'fields/show', to: 'fields#show'

  resources :replies, only: :create

  root "tickets#index"
end
