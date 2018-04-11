Rails.application.routes.draw do

  mount Comments::Engine => "/comments"
end
