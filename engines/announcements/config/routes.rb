Announcements::Engine.routes.draw do
  namespace :admin do
    resources :announcements do
      put :deliver
      put :test
      get :show_users
      get :show_recipients
      post :select_recipients
    end

    root "announcements#index"
  end
end
