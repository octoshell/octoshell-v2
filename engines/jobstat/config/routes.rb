Jobstat::Engine.routes.draw do
  get 'account/list/index' => "account_list#index"
  get 'account/list/all_rules' => "account_list#all_rules"
  post 'account/list/feedback' => "account_list#feedback"
  post 'job/feedback' => "account_list#feedback"
  # post 'account/list/feedback_job' => "account_list#feedback_job"
  # post 'account/list/feedback_jobs' => "account_list#feedback_jobs"
  # post 'account/list/feedback_rule' => "account_list#feedback_rule"
  get 'account/summary/show' => "account_summary#show"
  get 'account/summary/download' => "account_summary#download"

  get 'job/detailed' => "job#detailed"

  resources :job

  get 'job/:cluster/:drms_job_id' => "job#show_direct"
  get 'api/check_exist' => "api#check_exist"

  post 'api/check_exist' => "api#check_exist"

  post 'job/info' => "api#post_info"
  post 'job/performance' => "api#post_performance"
  post 'job/digest' => "api#post_digest"
  post 'job/tags' => "api#post_tags"
  post 'job/detailed' => "api#post_detailed"
end
