Jobstat::Engine.routes.draw do
  get 'account/list/index' => "account_list#index"
  get 'account/summary/show' => "account_summary#show"

  resources :job

  get 'job/:cluster/:drms_job_id' => "job#show_direct"

  post 'job/info' => "api#post_info"
  post 'job/performance' => "api#post_performance"
  post 'job/tags' => "api#post_tags"
end
