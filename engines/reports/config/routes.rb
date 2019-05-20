Reports::Engine.routes.draw do
	root "constructor#show"
	resources :constructor, only: %i[show] do
		collection do
			get :class_info
			post :csv
			post :array
			post :to_sql

		end
	end
end
