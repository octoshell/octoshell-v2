Sessions::Engine.routes.draw do
  resources :reports, only: [:index, :show, :edit, :update] do
    put :accept
    put :decline_submitting
    patch :submit
    patch :resubmit
    post :replies
  end

  resources :user_surveys, path: :surveys, only: [:index, :show, :edit, :update] do
    put :accept
    patch :submit
  end

  namespace :admin do
    resources :reports, only: [:show, :index] do
      get :find_similar, on: :member
      get :find_similar_by_members, on: :member
      patch :pick
      patch :assess
      patch :reject
      put :edit
      post :replies
      patch :change_expert
    end

    resources :report_submit_denial_reasons

    resources :sessions, only: [:new, :create, :index, :show] do
      put :start
      put :stop
      put :download
      put :notify_experts
      # get :show_projects
      # post :select_projects
      get :show_projects, to: 'projects#show_projects'
      post :select_projects, to: 'projects#select_projects'

      resources :stats, expect: [:index, :show]
      resources :surveys, only: [:new, :create, :edit, :update]
    end

    # resources :projects do
    # get 'sessions/show_projects/:session_id', to: 'projects#show_projects'
    # post 'sessions/select_projects/:session_id', to: 'projects#select_projects'
    # end

    get "/stats/:stat_id/download" => "stats#download", as: :stat_download
    get "/stats/:stat_id/detail" => "stats#detail", as: :stat_detail

    resources :surveys, except: [:edit, :update, :index] do
      resources :survey_fields, except: :index, path: :fields
    end

    resources :user_surveys, only: :show

    root "sessions#index"
  end

  root "reports#index"
end
