Jobstat::Engine.routes.draw do
  resources :digest_string_data
  resources :digest_float_data
  resources :float_data
  resources :string_data
  resources :jobs
end
