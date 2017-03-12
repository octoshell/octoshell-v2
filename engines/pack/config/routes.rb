Pack::Engine.routes.draw do
  
  namespace  :admin do


  root "packages#index"
  resources :accesses
  resources :packages do
    
  	resources :versions 
  end
  resources :versions

  resources :accesses do
    get :autocomplete_package_name, :on => :collection
  end
  	
  	
  end

  #match "/packages_json" => "packages#index", :via => :post
  match "/access_to" => "uservers#manage_access", :via => :all
  match "/edit_rights" => "uservers#edit", :via => :all
  match "/vers_json" => "uservers#get_vers", :via => :all
  root "packages#index"
  resources :packages do
    collection do
      get 'json'
      post 'remember_pref'
    end
  	#resources :versions 

  end
  resources :accesses,only: [:create,:update]  do
    collection do
      get 'form'
    end  
  end
  delete 'destroy_request/:id',to: 'accesses#destroy_request',as: 'access_req'
end
