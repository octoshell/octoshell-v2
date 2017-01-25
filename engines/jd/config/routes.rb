Jd::Engine.routes.draw do
  get "user_stat" => "user_stat#show_table"
  post "user_stat" => "user_stat#show_table"

  get "task_table" => "project_tasks#show_table"
  post "task_table" => "project_tasks#show_table"
end
