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
    get :autocomplete_user_name, :on => :collection
    collection do
      post '/search/:username' => 'users#search' #, as: 'search'
      post '/search' => 'users#search', as: 'search'
    end
  end

  resources :motions, only: [:show, :edit, :delete, :destroy] do
    post 'vote/:for'      => 'votes/motions#create',   as: 'vote'
    delete 'vote'         => 'votes/motions#destroy',  as: 'vote_delete'

    get 'tags',      to: 'tags/motions#index', on: :collection
    get 'tags/:tag', to: 'tags/motions#show',  on: :collection, as: :tag
  end

  resources :questions, only: [:show, :update] do
    resources :motions, only: [:new, :create]
  end

  resources :arguments do
    resources :comments

    post   'vote' => 'votes/arguments#create'
    delete 'vote' => 'votes/arguments#destroy'
  end

  resources :opinions do
    resources :comments
  end

  resources :forums, except: [:index, :edit] do
    get :settings, on: :member
    resources :memberships, only: [:create, :destroy]
    resources :questions, only: [:index, :new, :create]
  end

  resources :pages, only: :show do
    get :settings, on: :member
  end

  namespace :portal do
    resources :pages, only: [:show, :new, :create]
    resources :forums, only: [:new, :create]
  end

  resources :profiles

  match '/search/' => 'search#show', as: 'search', via: [:get, :post]

  ##get "users/new"
  get '/settings', to: 'users#edit', as: 'settings'
  post '/settings', to: 'users#update'
  #match "/signup", to: "users#new"
  #match "/signin", to: "sessions#new"
  #get "/signout", to: "sessions#destroy", via: :delete
  get '/about', to: 'static_pages#about'

  get '/portal', to: 'portal/portal#home'

  root to: 'static_pages#home'
  get '/', to: 'motions#index'
  get '/home', to: 'motions#index'
end
