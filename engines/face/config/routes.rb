Face::Engine.routes.draw do
  root "home#show"
  resources :menu_items do
    collection do
      get :edit_all
      put :update_all
    end
  end
end
