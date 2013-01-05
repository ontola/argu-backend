Argu::Application.routes.draw do
  resources :authentications, only: [:create, :destoy]
  match 'auth/:provider/callback' => "authentications#create"

  devise_for :users, :controllers => { :registrations => 'registrations' }

  #resources :users
  resources :statements do 
    get :autocomplete_argument_title, :on => :collection
  end
  get "/statements/:id/revisions" => "statements#allrevisions", as: 'revisions_statement'
  get "/statements/:id/revisions/:rev" => "statements#revisions", as: 'rev_revisions_statement'
  put "/statements/:id/revisions/:rev" => "statements#setrevision", as: 'update_revision_statement'

  resources :arguments
  post "/arguments/:id/placeComment" => "arguments#placeComment"
  get "/arguments/:id/revisions" => "arguments#allrevisions", as: 'revisions_argument'
  get "/arguments/:id/revisions/:rev" => "arguments#revisions", as: 'rev_revisions_argument'
  put "/arguments/:id/revisions/:rev" => "arguments#setrevision", as: 'update_revision_argument'
  
  #resources :sessions #, only: [:new, :create, :destroy]
  resources :profiles
  resources :votes
  resources :comments

  get "/search/" => "search#show", as: 'search'
  post "/search/" => "search#show", as: 'search'

  ##get "users/new"

  root to: 'static_pages#home'

  match "/", to: "static_pages#home"
  match "/home", to: "static_pages#home"
  get "/settings", to: "users#show"
  post '/settings' => 'users#update'
  #match "/signup", to: "users#new"
  #match "/signin", to: "sessions#new"
  #get "/signout", to: "sessions#destroy", via: :delete
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
