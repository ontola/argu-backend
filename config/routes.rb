Argu::Application.routes.draw do
  root to: 'static_pages#home'
  match "/", to: "static_pages#home", constraints: lambda { |r| r.env["warden"].authenticate? }
  match "/home", to: "static_pages#home", constraints: lambda { |r| r.env["warden"].authenticate? }

  devise_for :users, :controllers => { :registrations => 'registrations' }

  resources :authentications, only: [:create, :destoy], constraints: lambda { |r| r.env["warden"].authenticate? }
  match 'auth/:provider/callback' => "authentications#create", constraints: lambda { |r| r.env["warden"].authenticate? }


  #resources :users
  resources :statements, constraints: lambda { |r| r.env["warden"].authenticate? }
  get "/statements/:id/revisions" => "statements#allrevisions", as: 'revisions_statement', constraints: lambda { |r| r.env["warden"].authenticate? }
  get "/statements/:id/revisions/:rev" => "statements#revisions", as: 'rev_revisions_statement', constraints: lambda { |r| r.env["warden"].authenticate? }
  put "/statements/:id/revisions/:rev" => "statements#setrevision", as: 'update_revision_statement', constraints: lambda { |r| r.env["warden"].authenticate? }

  resources :arguments, constraints: lambda { |r| r.env["warden"].authenticate? }
  post "/arguments/:id/placeComment" => "arguments#placeComment", constraints: lambda { |r| r.env["warden"].authenticate? }
  get "/arguments/:id/revisions" => "arguments#allrevisions", as: 'revisions_argument', constraints: lambda { |r| r.env["warden"].authenticate? }
  get "/arguments/:id/revisions/:rev" => "arguments#revisions", as: 'rev_revisions_argument', constraints: lambda { |r| r.env["warden"].authenticate? }
  put "/arguments/:id/revisions/:rev" => "arguments#setrevision", as: 'update_revision_argument', constraints: lambda { |r| r.env["warden"].authenticate? }
  
  #resources :sessions #, only: [:new, :create, :destroy]
  resources :profiles, constraints: lambda { |r| r.env["warden"].authenticate? }
  resources :votes, constraints: lambda { |r| r.env["warden"].authenticate? }
  match "/arguments/:id/upvote" => "votes#create", as: 'argument_create_vote', constraints: lambda { |r| r.env["warden"].authenticate? }
  match "/arguments/:id/unvote" => "votes#destroy", as: 'argument_destroy_vote', constraints: lambda { |r| r.env["warden"].authenticate? }
  resources :comments, constraints: lambda { |r| r.env["warden"].authenticate? }

  get "/search/" => "search#show", as: 'search', constraints: lambda { |r| r.env["warden"].authenticate? }
  post "/search/" => "search#show", as: 'search', constraints: lambda { |r| r.env["warden"].authenticate? }

  ##get "users/new"
  get "/settings", to: "users#show", constraints: lambda { |r| r.env["warden"].authenticate? }
  post '/settings' => 'users#update', constraints: lambda { |r| r.env["warden"].authenticate? }
  #match "/signup", to: "users#new"
  #match "/signin", to: "sessions#new"
  #get "/signout", to: "sessions#destroy", via: :delete
  match "/about", to: "static_pages#about", constraints: lambda { |r| r.env["warden"].authenticate? }
  match "/learn", to: "static_pages#learn", constraints: lambda { |r| r.env["warden"].authenticate? }
  match "/newpage", to: "static_pages#newlayout", constraints: lambda { |r| r.env["warden"].authenticate? }
end
