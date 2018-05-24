Jobstat::Engine.routes.draw do
  get 'account/list/index' => "account_list#index"
  get 'account/summary/show' => "account_summary#show"

  resources :job
  resources :job_analysis

  post 'job/info' => "job#post_info"
  post 'job/performance' => "job#post_performance"
  post 'job/tags' => "job#post_tags"
  post 'api/push' => 'api/push'

end
