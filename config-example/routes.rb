InfrastructureDb::Application.routes.draw do
  get 'login', to: 'sessions#new', as: 'login'
  post 'login', to: 'sessions#create', as: 'loggin'
  delete 'logout', to: 'sessions#destroy', as: 'logout'

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  get 'background_jobs/sidekiq', to: 'background_jobs#sidekiq'

  resources :machines do
    get :autocomplete_config_instructions, :on => :collection
    get :autocomplete_sw_characteristics, :on => :collection
    get :autocomplete_business_purpose, :on => :collection
    get :autocomplete_business_criticality, :on => :collection
    get :autocomplete_business_notification, :on => :collection
    member do
      get 'maintenance_record/new', to: 'maintenance_records#new'
    end

    patch 'details', to: 'machines#update_details'
  end
  resources :networks
  resources :owners
  get 'owners_summary/:owner', to: 'owners#summary', as: 'owners_summary'
  resources :maintenance_records, only: [:show, :index, :new, :create, :update] do
    get :download_log, to: 'maintenance_records#download_log'
  end
  resources :versions
  # we need to allow dots in the fqdn we pass as :id
  resources :untracked_machines, only: [:index, :destroy], :constraints => { :id => /[^\/]+/ }
  resources :deleted_machines, only: [:index, :edit, :destroy]
  resources :deleted_owners, only: [:index, :edit, :destroy]
  resources :outdated_machines, only: [:index]
  resources :lexware_imports, only: [:new, :create]
  resources :inventory_imports, only: [:new, :create]
  resources :inventories do
    get :autocomplete_inventory_category, :on => :collection
    get :autocomplete_inventory_name, :on => :collection
    get :autocomplete_inventory_place, :on => :collection
    get :autocomplete_inventory_seller, :on => :collection
  end
  resources :attachments, only: [:destroy]
  resources :locations do
    get :get_parent_locations, :on => :collection
  end
  resources :location_levels
  resources :inventory_status
  resources :api_tokens
  resources :softwares, only: [:index]
  resources :cloud_providers
  resources :users, only: [:index, :edit, :update]
  resources :maintenance_announcements do
    get :autocomplete_maintenance_announcement_email, :on => :collection
  end
  resources :maintenance_templates

  post 'markup/render', to: 'markup#do_render'

  root 'machines#index'

  mount API => '/api'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end
  
  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
