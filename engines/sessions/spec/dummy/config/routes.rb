Rails.application.routes.draw do

  mount Sessions::Engine => "/sessions"
end
