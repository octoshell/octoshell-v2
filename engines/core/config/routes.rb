Core::Engine.routes.draw do
  resources :bot_links_api
  resources :bot_links do
    get :generate
  end
  namespace :admin do
    resources :notices do
      get :hide
    end
    resources :members, only: :index
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
      put :activate_or_reject
    end

    resources :project_kinds
    resources :organization_kinds

    resources :countries
    resources :cities do
      member do
        post :merge
      end
    end
    resources :prepare_merge,only: [:index,:update,:edit] do
      member do
        delete :destroy
      end
    end
    resources :organizations do
      member do
        get :index_for_organization
        put :check
      end
      collection do
        get :merge_edit
        post :merge_update
      end
      resources :departments, except: :show
    end

    resources :direction_of_sciences
    resources :critical_technologies
    resources :research_areas
    resources :group_of_research_areas, except: :index

    resources :requests, only: [:index, :show, :edit, :update] do
      get :approve, on: :member
      get :reject, on: :member
      put :activate_or_reject, on: :member
    end

    resources :quota_kinds, except: :show

    resources :clusters
    resources :cluster_logs, only: :index

    resources :users, only: :index do
      collection do
        get :owners_finder
        get :with_owned_projects_finder
      end
      get :block, on: :member
      get :reactivate, on: :member
    end
  end

  resources :notices do
    post :visible
    get :hide
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
      delete :delete_invitation
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

  resources :organizations, except: [:destroy] do
    resources :organization_departments, path: :departments, only: [:index, :new, :create]
  end

  resources :countries, only: :index do
    resources :cities, only: [:index, :show]
  end
  resources :cities do
    collection do
      get :index_for_country
      get :finder
    end
  end
  root "projects#index"
end
# Face::MyMenu.validate_keys!
