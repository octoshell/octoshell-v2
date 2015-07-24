Core::Engine.routes.draw do
  namespace :admin do
    resources :projects do
      member do
        get :activate
        get :cancel
        get :suspend
        get :block
        get :unblock
        get :reactivate
        get :finish
        get :resurrect
        get :synchronize_with_clusters
      end

      resources :requests, only: [:new, :create]
    end

    resources :sureties do
      collection do
        post :find
        get :template,     action: :edit_template
        put :template,     action: :update_template
        put :default,      action: :default_template
        put :rtf_template
        put :default_rtf
        get :rtf_template, action: :download_rtf_template
      end
      put :activate
      put :close
      put :confirm
      put :reject
    end

    resources :project_kinds
    resources :organization_kinds

    resources :organizations, only: [:new, :create, :index, :show, :edit, :update] do
      resources :departments, except: :show
    end

    resources :direction_of_sciences
    resources :critical_technologies
    resources :research_areas

    resources :requests, only: [:index, :show, :edit, :update] do
      get :approve, on: :member
      get :reject, on: :member
    end

    resources :quota_kinds, except: :show

    resources :clusters
    resources :cluster_logs, only: :index

    resources :users, only: :index do
      get :block, on: :member
      get :reactivate, on: :member
    end
  end

  resources :credentials, only: [:new, :create] do
    put :deactivate
  end

  resources :employments

  resources :projects do
    member do
      get :cancel
      get :suspend
      get :reactivate
      get :finish
      get :resurrect

      post :invite_member
      post :invite_users_from_csv
      post :resend_invitations
      put :drop_member
    end

    post :sureties
    put :toggle_member_access_state, on: :collection

    resources :requests, only: [:new, :create]
    resources :members, only: [:edit, :update, :create]
  end

  resources :sureties do
    get :confirm, on: :member
    get :close, on: :member
  end

  resources :organization_kinds, only: :index

  resources :organizations, except: :destroy do
    resources :organization_departments, path: :departments, only: [:index, :new, :create]
  end

  resources :countries, only: :index do
    resources :cities, only: [:index, :show]
  end

  root "projects#index"
end
