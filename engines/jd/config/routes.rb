Jd::Engine.routes.draw do
  get "user_stat" => "user_stat#show_table"
  post "user_stat" => "user_stat#show_table"
end
