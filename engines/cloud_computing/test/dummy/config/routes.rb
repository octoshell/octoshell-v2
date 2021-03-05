Rails.application.routes.draw do
  mount CloudComputing::Engine => "/cloud_computing"
end
