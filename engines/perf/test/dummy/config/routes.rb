Rails.application.routes.draw do
  mount Perf::Engine => "/perf"
end
