Comments::Engine.routes.draw do
  resources :comments, only: :destroy do
    collection do
      post 'update'
      post 'create'
      get 'index'
      get 'index_all'
    end
  end
  resources :tags, only: :destroy do
    collection do
      post 'update'
      post 'create'
      get 'index'
      get 'index_all'
    end
  end
  resources :tags_lookup
  resources :files, only: :destroy do
    collection do
      post 'update'
      post 'create'
      get 'index'
      get 'index_all'
    end
  end
  get 'secured_uploads/:id/:file_name', action: :show_file, controller: 'files'
  namespace :admin do
    resources :group_classes, only: [] do
      collection do
        post 'update'
        get 'edit'
        get 'list_objects'
        get 'type_abs'
      end
    end
    resources :context_groups, only: [] do
      collection do
        post 'update'
        get 'edit'
        get 'type_abs'
      end
    end

    resources :contexts, except: :show
  end
end
