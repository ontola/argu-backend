Argu::Application.routes.draw do
  resources :users
  resources :statements do 
    get :autocomplete_argument_title, :on => :collection
  end
  get "/statements/:id/revisions" => "statements#allrevisions", as: 'revisions_statement'
  get "/statements/:id/revisions/:rev" => "statements#revisions", as: 'rev_revisions_statement'
  put "/statements/:id/revisions/:rev" => "statements#setrevision", as: 'update_revision_statement'

  resources :arguments
  post "/arguments/:id/placeComment" => "arguments#placeComment"
  
  resources :sessions, only: [:new, :create, :destroy]
  resources :statementarguments
  resources :votes
  resources :comments

  #get "users/new"
  get "/users/:id/settings" => "users#settings"
  post "/users/:id/settings" => "users#settingsUpdate"

  root to: 'static_pages#home'

  match "/", to: "static_pages#home"
  match "/home", to: "static_pages#home"
  match "/signup", to: "users#new"
  match "/signin", to: "sessions#new"
  match "/signout", to: "sessions#destroy", via: :delete
  match "/about", to: "static_pages#about"
  match "/learn", to: "static_pages#learn"
  match "/newpage", to: "static_pages#newlayout"


  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # See how all your routes lay out with "rake routes"
end
