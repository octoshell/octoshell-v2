Rails.application.routes.draw do

  mount Authentication::Engine => "/authentication"
end
