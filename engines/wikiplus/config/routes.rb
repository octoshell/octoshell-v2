Wikiplus::Engine.routes.draw do
	resources :tasks
  	resources :pages
  	resources :images

  	resources :pages do
  		member do
  			post :createsubpage
  			get :newsubpage
  		end
  	end
  	root "pages#index"
end
