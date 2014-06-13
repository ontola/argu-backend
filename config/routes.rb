Argu::Application.routes.draw do

  devise_for :users, :controllers => { :registrations => 'registrations' }

  namespace :admin do
    get 'list' => 'administration#list'
    post ':id' => 'administration#add'
    delete ':id' => 'administration#remove', as: 'remove'
    post 'freeze/:id' => 'administration#freeze', as: 'freeze'
    delete 'freeze/:id' => 'administration#unfreeze'
    #post 'search_username' => 'administration#search_username', constraints: lambda { |r| r.env["warden"].authenticate? }
    root to: 'administration#panel'
  end

  resources :authentications, only: [:create, :destroy]
  match 'auth/:provider/callback' => 'authentications#create', via: [:get, :post]
  
  get 'tagged' => 'statements#tagged', :as => 'tagged'

  resources :users do
    collection do
      post '/search/:username' => 'users#search' #, as: 'search'
      post '/search' => 'users#search', as: 'search'
    end
  end

  resources :statements do
    get 'revisions' => 'statements#allrevisions', as: 'revisions'
    get 'revisions/:rev' => 'statements#revisions', as: 'rev_revisions'
    put 'revisions/:rev' => 'statements#setrevision', as: 'update_revision'
    post 'vote' => 'statements#vote'
    delete 'vote' => 'statements#destroy_vote'
    namespace :moderators do# , except: [:new, :update], controller: 'moderators/statements'
      get '' => 'statements#index', as: ''
      post ':user_id' => 'statements#create', as: 'user'
      delete ':user_id' => 'statements#destroy'
    end
  end

  resources :arguments do
    delete 'argument/:id' => 'arguments#destroy', as: 'destroy'
    post 'comments' => 'arguments#placeComment'
    delete 'comments/:comment_id' => 'arguments#destroyComment', as: 'destroy_comments'
    
    get 'revisions' => 'arguments#allrevisions', as: 'revisions'
    get 'revisions/:rev' => 'arguments#revisions', as: 'rev_revisions'
    put 'revisions/:rev' => 'arguments#setrevision', as: 'update_revision'
    
    post 'upvote' => 'votes#create', as: 'create_vote'
    post 'unvote' => 'votes#destroy', as: 'destroy_vote'
  end
  
  #resources :sessions #, only: [:new, :create, :destroy]
  resources :profiles
  resources :votes
  resources :comments
  resources :cards do
    resources :card_pages, as: 'pages', path: 'pages'
  end

  match '/search/' => 'search#show', as: 'search', via: [:get, :post]
  #post '/search/' => 'search#show', as: 'search'

  ##get "users/new"
  get '/settings', to: 'users#edit', as: 'settings'
  post '/settings', to: 'users#update'
  #match "/signup", to: "users#new"
  #match "/signin", to: "sessions#new"
  #get "/signout", to: "sessions#destroy", via: :delete
  get '/about', to: 'static_pages#about'
  get '/learn', to: 'static_pages#learn'
  get '/newpage', to: 'static_pages#newlayout'

  root to: 'static_pages#home'
  get '/', to: 'statements#index'
  get '/home', to: 'statements#index'
end
