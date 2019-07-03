# == Route Map
#

Api::Engine.routes.draw do
  get '/req/:req', to: 'api#api_request'
  get '/', to: redirect('/api/admin/access_keys')

  namespace :admin do
    resources :access_keys
    resources :exports
    resources :key_parameters
  end
end
