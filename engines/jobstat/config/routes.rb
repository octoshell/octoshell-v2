Jobstat::Engine.routes.draw do
  get 'account/list/index' => "account_list#index"
  get 'account/summary/show' => "account_summary#show"

  resources :job

  post 'job/info' => "api#post_info"
  post 'job/performance' => "api#post_performance"
  post 'job/tags' => "api#post_tags"
end
