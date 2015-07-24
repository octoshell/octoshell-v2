Rails.application.routes.draw do

  mount Wiki::Engine => "/wiki"
end
