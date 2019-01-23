require "sidekiq/web"
require "admin_constraint"

Octoshell::Application.routes.draw do
  mount RailsEmailPreview::Engine, at: '/admin/emails'
  # This line mounts Wiki routes at /wiki by default.
  mount Wiki::Engine, :at => "/wiki"

  # This line mounts Jobstat routes at /jobstat by default.
  mount Jobstat::Engine, at: "/jobstat"

  # This line mounts Statistics routes at /stats by default.
  mount Statistics::Engine, :at => "/admin/stats"

  # This line mounts Sessions's routes at /sessions by default.
  mount Sessions::Engine, :at => "/sessions"

  # This line mounts Support's routes at /support by default.
  mount Support::Engine, :at => "/support"

  # This line mounts Core's routes at /core by default.
  mount Core::Engine, :at => "/core"

  # This line mounts Face's routes at / by default.
  mount Face::Engine, at: "/"

  # This line mounts Authentication's routes at /auth by default.
  mount Authentication::Engine, at: "/auth"

  mount Pack::Engine, at: "/pack"
  mount Announcements::Engine, :at => "/announcements"
  mount Comments::Engine, :at => "/comments"
  mount Hardware::Engine, at: "/hardware"

  root "face/home#show"

  resources :users do
    get :login_as, on: :member
    get :return_to_self, on: :member
  end

  resources :lang_prefs, only: {} do
    collection do
      post :change
    end
  end

  resource :profile

  resources :options, only: [] do
    collection do
      get :categories
    end

    member do
      get :values
    end

  end


  namespace :admin do
    mount Sidekiq::Web => "/sidekiq", :constraints => AdminConstraint.new

    resources :users do
      member do
        post :block_access
        post :unblock_access
      end
    end

    resources :groups do
      put :default, on: :collection
    end

    resources :options_categories do

    end


  end
end
