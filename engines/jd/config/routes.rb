Jd::Engine.routes.draw do
  get "job_stat" => "user_stat#show_stat"
  post "job_stat" => "user_stat#query_stat"

  get "job_table" => "project_tasks#show_table"
  post "job_table" => "project_tasks#query_table"

  get 'project/:id', to: "project_stat#show"
end
