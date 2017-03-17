Jd::Engine.routes.draw do
  get "job_stat" => "user_stat#show_table"
  post "job_stat" => "user_stat#show_table"

  get "job_table" => "project_tasks#show_table"
  post "job_table" => "project_tasks#show_table"
end
