Octoface::Engine.routes.draw do
  namespace :admin do
    resources :roles, only: :index
    get 'roles/:name', to: 'roles#show', as: 'role'
  end
end
