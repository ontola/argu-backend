Argu::Application.routes.draw do

  devise_for :users, :controllers => { :registrations => 'registrations' }

  resources :authentications, only: [:create, :destoy]
  match 'auth/:provider/callback' => "authentications#create"


  #resources :users
  resources :statements do
    get "revisions" => "statements#allrevisions", as: 'revisions', constraints: lambda { |r| r.env["warden"].authenticate? }
    get "revisions/:rev" => "statements#revisions", as: 'rev_revisions', constraints: lambda { |r| r.env["warden"].authenticate? }
    put "revisions/:rev" => "statements#setrevision", as: 'update_revision', constraints: lambda { |r| r.env["warden"].authenticate? }
  end

  resources :arguments, constraints: lambda { |r| r.env["warden"].authenticate? } do
    post "comment" => "arguments#placeComment", constraints: lambda { |r| r.env["warden"].authenticate? }
    delete "comment/:id" => "arguments#wipeComment", constraints: lambda { |r| r.env["warden"].authenticate? }
    
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
  get "/settings", to: "users#show", as: 'settings', constraints: lambda { |r| r.env["warden"].authenticate? }
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
