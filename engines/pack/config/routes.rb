Pack::Engine.routes.draw do
  
  namespace  :admin do

match "/get_projects" => "uservers#get_projects", :via => :get  	
#match "/packages_json" => "packages#index", :via => :post
  match "/access_to" => "uservers#manage_access", :via => :get
  match "/edit_rights" => "uservers#edit", :via => :post
  match "/vers_json" => "uservers#get_vers", :via => :get
   match "/get_project_vers" => "uservers#get_project_vers", :via => :get
   match "/edit_projects_vers" => "uservers#edit_projects", :via => :post
  root "packages#index"
  resources :packages do
    collection do
      post 'packages_json'
    end
  	resources :versions 
  end
  #resources :versions,only: [:]

  resources :uservers do
    get :autocomplete_user_email, :on => :collection
  end
  	
  	
  end

  #match "/packages_json" => "packages#index", :via => :post
  match "/access_to" => "uservers#manage_access", :via => :all
  match "/edit_rights" => "uservers#edit", :via => :all
  match "/vers_json" => "uservers#get_vers", :via => :all
  root "packages#index"
  resources :packages do
    collection do
      post 'packages_json'
      post 'remember_pref'
    end
  	resources :versions 
  end
end
