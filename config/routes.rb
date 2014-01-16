Argu::Application.routes.draw do

  devise_for :users, :controllers => { :registrations => 'registrations' }

  namespace :admin do
    get 'list' => 'administration#list', constraints: lambda { |r| r.env["warden"].authenticate? }
    post 'admin/:id' => 'administration#add', constraints: lambda { |r| r.env["warden"].authenticate? }
    delete 'admin/:id' => 'administration#remove', as: 'remove', constraints: lambda { |r| r.env["warden"].authenticate? }
    #post 'search_username' => 'administration#search_username', constraints: lambda { |r| r.env["warden"].authenticate? }
    root to: 'administration#panel', constraints: lambda { |r| r.env["warden"].authenticate? }
  end

  resources :authentications, only: [:create, :destoy]
  match 'auth/:provider/callback' => "authentications#create"
  
  match 'tagged' => 'statements#tagged', :as => 'tagged'

  resources :users do
    collection do
      post '/search/:username' => 'users#search', as: 'search'
      post '/search' => 'users#search', as: 'search'
    end
  end

  resources :statements do
    get "revisions" => "statements#allrevisions", as: 'revisions', constraints: lambda { |r| r.env["warden"].authenticate? }
    get "revisions/:rev" => "statements#revisions", as: 'rev_revisions', constraints: lambda { |r| r.env["warden"].authenticate? }
    put "revisions/:rev" => "statements#setrevision", as: 'update_revision', constraints: lambda { |r| r.env["warden"].authenticate? }
    namespace :moderators do# , except: [:new, :update], controller: 'moderators/statements'
      get '' => 'statements#index', as: ''
      post ':user_id' => 'statements#create', as: 'user'
      delete ':user_id' => 'statements#destroy'
    end
  end

  resources :arguments, constraints: lambda { |r| r.env["warden"].authenticate? } do
    delete "argument/:id" => "arguments#destroy", as: 'destroy', constraints: lambda { |r| r.env["warden"].authenticate? }
    post "comments" => "arguments#placeComment", constraints: lambda { |r| r.env["warden"].authenticate? }
    delete "comments/:comment_id" => "arguments#destroyComment", as: 'destroy_comments', constraints: lambda { |r| r.env["warden"].authenticate? }
    
    get "revisions" => "arguments#allrevisions", as: 'revisions', constraints: lambda { |r| r.env["warden"].authenticate? }
    get "revisions/:rev" => "arguments#revisions", as: 'rev_revisions', constraints: lambda { |r| r.env["warden"].authenticate? }
    put "revisions/:rev" => "arguments#setrevision", as: 'update_revision', constraints: lambda { |r| r.env["warden"].authenticate? }
    
    match "upvote" => "votes#create", as: 'create_vote', constraints: lambda { |r| r.env["warden"].authenticate? }
    match "unvote" => "votes#destroy", as: 'destroy_vote', constraints: lambda { |r| r.env["warden"].authenticate? }
  end
  
  #resources :sessions #, only: [:new, :create, :destroy]
  resources :profiles, constraints: lambda { |r| r.env["warden"].authenticate? }
  resources :votes, constraints: lambda { |r| r.env["warden"].authenticate? }
  resources :comments, constraints: lambda { |r| r.env["warden"].authenticate? }

  get "/search/" => "search#show", as: 'search', constraints: lambda { |r| r.env["warden"].authenticate? }
  post "/search/" => "search#show", as: 'search', constraints: lambda { |r| r.env["warden"].authenticate? }

  ##get "users/new"
  get "/settings", to: "users#edit", as: 'settings', constraints: lambda { |r| r.env["warden"].authenticate? }
  post '/settings' => 'users#update', as: 'settings', constraints: lambda { |r| r.env["warden"].authenticate? }
  #match "/signup", to: "users#new"
  #match "/signin", to: "sessions#new"
  #get "/signout", to: "sessions#destroy", via: :delete
  match "/about", to: "static_pages#about", constraints: lambda { |r| r.env["warden"].authenticate? }
  match "/learn", to: "static_pages#learn", constraints: lambda { |r| r.env["warden"].authenticate? }
  match "/newpage", to: "static_pages#newlayout", constraints: lambda { |r| r.env["warden"].authenticate? }

  root to: 'static_pages#home'
  match "/", to: "statements#index", constraints: lambda { |r| r.env["warden"].authenticate? }
  match "/home", to: "statements#index", constraints: lambda { |r| r.env["warden"].authenticate? }
end
