Pack::Engine.routes.draw do
  
  namespace  :admin do


  root "packages#index"
  resources :accesses do
    member do
      post 'manage_access'
    end
  end
  resources :packages do
    
  	resources :versions 
  end
  resources :versions

  resources :accesses 

  resources :options_categories

  get 'get_groups',to: 'accesses#get_groups',as: 'get_groups'
  	
  	
  end

  root "packages#index"
  resources :versions,only: :show
  resources :packages do
    collection do
      get 'json'
      
    end
  
  end
  resources :accesses,only: []  do
    collection do
      get 'form'
      post 'update'
      post 'destroy'
    end

  end
 
end
