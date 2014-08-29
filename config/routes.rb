Argu::Application.routes.draw do
  get '/', to: 'static_pages#developers', constraints: { subdomain: 'developers'}
  get '/developers', to: 'static_pages#developers'
  devise_for :users, :controllers => { :registrations => 'registrations' }

  resource :admin do
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

  resources :users do
    collection do
      post '/search/:username' => 'users#search' #, as: 'search'
      post '/search' => 'users#search', as: 'search'
    end
  end

  resources :statements do
    post 'vote/:for'      => 'votes/statements#create',   as: 'vote'
    delete 'vote'         => 'votes/statements#destroy',  as: 'vote_delete'

    get 'tags',      to: 'tags/statements#index', on: :collection
    get 'tags/:tag', to: 'tags/statements#show',  on: :collection, as: :tag

    resources :revisions, only: [:index, :show, :update], shallow: true
    #member do
    #  get 'tags'   # refactor above to this later (or, ideally a new controller on its own)
    #end
    namespace :moderators do# , except: [:new, :update], controller: 'moderators/statements'
      get '' => 'statements#index', as: ''
      post ':user_id' => 'statements#create', as: 'user'
      delete ':user_id' => 'statements#destroy'
    end
  end

  resources :arguments do
    resources :comments
    resources :revisions, only: [:index, :show, :update], shallow: true
    
    post   'vote' => 'votes/arguments#create'
    delete 'vote' => 'votes/arguments#destroy'
  end

  resources :opinions do
    resources :comments
  end

  #resources :sessions #, only: [:new, :create, :destroy]
  resources :profiles
  resources :votes

  match '/search/' => 'search#show', as: 'search', via: [:get, :post]

  ##get "users/new"
  get '/settings', to: 'users#edit', as: 'settings'
  post '/settings', to: 'users#update'
  #match "/signup", to: "users#new"
  #match "/signin", to: "sessions#new"
  #get "/signout", to: "sessions#destroy", via: :delete
  get '/about', to: 'static_pages#about'

  root to: 'static_pages#home'
  get '/', to: 'statements#index'
  get '/home', to: 'statements#index'
end
