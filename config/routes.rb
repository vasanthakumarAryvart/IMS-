require 'sidekiq/web'

Rails.application.routes.draw do
   # devise_for :users

    devise_for :users, path: 'auth_users', controllers: {
          sessions: 'users/sessions',registrations: 'users/registrations',passwords: 'users/passwords'
    }

    # devise_scope :user do
    #   root :to => 'devise/sessions#new'
    # end
  
    # devise_for :users, path: 'auth_users', controllers: {
    #       sessions: 'users/sessions',registrations: 'users/registrations',passwords: 'users/passwords'
    # }

    # devise_scope :user do
    #   root :to => 'devise/sessions#new'
    # end
  post 'post_warehouse', to: 'warehouses#post_warehouse', as: :post_warehouse
  post 'post_shipping', to: 'shipping_presets#post_shipping', as: :post_shipping  
  get '/dashboard' => 'dashboard#index', :as => :dashboard
  get '/shipping' => 'dashboard#shipping', :as => :shipping
  get '/connected-accounts' => 'settings#accounts', :as => :connected_accounts
  get '/disconnect-account/:id' => 'settings#disconnect_account', :as => :disconnect_account
  get '/notifications' => 'settings#notifications', :as => :notifications

  #get '/reports' => 'reports#index', :as => :reports
  get '/reports/sales' => 'reports#sales', :as => :sales_report
  get '/reports/performance' => 'reports#performance', :as => :seller_performance_report
  get '/reports/sold-listings' => 'reports#sold_listings', :as => :sold_listings_report

  resources :listings do
    collection do
      get 'suggest-template' => "listings#suggest_template", :as => :suggest_template
      get 'inventory'
    end
    member do
      get 'unarchive' => 'listings#unarchive'
      get 'cancel-pending' => 'listings#cancel_pending'
    end
  end
  resources :warehouses
  resources :shipping_presets
  resources :warehouses do
    resources :pins, :controller => 'warehouse_pins'
  end
  resources :accounts, :only => %w{update}
  resources :orders do
    resources :order_items do
      collection do
        get 'inventory_search'
      end
    end
  end

  # default integration custom actions paths
  match '/integration/:account_id/connect' => 'integration_custom_actions#auth_connect', as: :connect_integration, :via => [:get, :post]
  match '/integration/:account_id/:action' => 'integration_custom_actions#action_missing', as: :integration_custom_action_for_account, :via => [:get, :post]
  match '/integration/:action' => 'integration_custom_actions#action_missing', as: :integration_custom_action, :via => [:get, :post]

  namespace :admin do
    get '/dashboard' => 'admin#dashboard', :as => :dashboard
    get '/notifications' => 'admin#notifications', :as => :notifications
    match '/settings' => 'admin#settings', :as => :settings, :via => [:get, :post]
    resources :item_categories, :path => 'categories' do
      resources :custom_fields, :path => 'custom-fields' do
        collection do
          post 'reorder'
        end
        resources :custom_field_mappings, :path => 'mappings'
      end
      resources :marketplace_category_mappings do
        collection do
          get 'marketplace-subcategories/:marketplace_id', :action => 'marketplace_subcategories', :as => :marketplace_subcategories
        end
      end
    end
    resources :listing_templates, :path => 'templates'
    resources :listings, :only => [:index]
    resources :orders, :only => [:index]
    resources :users, :only => [:index] do
      member do
        post :state, :as => :state
      end
    end
    resources :item_sources
    resources :inventory_items

    # reports
    #get '/reports' => 'reports#index', :as => :reports
    get '/reports/sales' => 'reports#sales', :as => :sales_report
    get '/reports/performance' => 'reports#performance', :as => :seller_performance_report
    get '/reports/sold-listings' => 'reports#sold_listings', :as => :sold_listings_report
  end

  root 'dashboard#index'

  authenticate :user, lambda { |u| u.try(:is_admin?) } do
    mount Sidekiq::Web, at: "/admin/sidekiq"
  end

end