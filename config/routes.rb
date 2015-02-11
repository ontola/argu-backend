Argu::Application.routes.draw do
  concern :moveable do
    get 'move', action: 'move'
    put 'move', action: 'move!'
  end
  concern :convertible do
    get 'convert', action: 'convert'
    put 'convert', action: 'convert!'
  end
  concern :votable do
    post 'vote/:for' => 'votes#create', shallow: true, as: :vote
  end


  put 'actors', to: 'actors#update'

  require 'sidekiq/web'

  get '/', to: 'static_pages#developers', constraints: { subdomain: 'developers'}
  get '/developers', to: 'static_pages#developers'
  devise_for :users, :controllers => { :registrations => 'registrations', :sessions => 'users/sessions', :invitations => 'users/invitations' }

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

  post 'vote/:for' => 'votes#create', as: :vote

  resources :questions, except: [:index, :new, :create], concerns: [:moveable, :convertible]

  resources :motions, except: [:index, :new, :create], concerns: [:moveable, :convertible, :votable]

  resources :arguments, except: [:index, :new, :create], concerns: [:votable] do
    resources :comments
    patch 'comments' => 'comments#create'
  end

  resources :opinions do
    resources :comments
  end

  resources :forums, except: [:edit] do
    get :settings, on: :member
    get :statistics, on: :member
    get :selector, on: :collection
    post :memberships, on: :collection
    resources :memberships, only: [:create, :destroy]
    resources :questions, only: [:index, :new, :create]
    resources :motions, only: [:new, :create]
    resources :arguments, only: [:new, :create]
    resources :tags, only: [:show]
  end

  resources :pages, only: [:new, :create, :show, :update, :delete, :destroy] do
    get :delete, on: :member
    get :settings, on: :member
  end

  authenticate :user, lambda { |p| p.profile.has_role? :staff } do
    resources :documents, only: [:edit, :update, :index, :new, :create]
    namespace :portal do
      get :settings, to: 'portal#settings'
      post 'settings', to: 'portal#setting!', as: :update_setting
      resources :forums, only: [:new, :create]
      mount Sidekiq::Web => '/sidekiq'
    end
  end

  resources :profiles do
    # This is to make requests POST if the user has an 'r' (which nearly all use POST)
    post ':id' => 'profiles#update', on: :collection
  end

  match '/search/' => 'search#show', as: 'search', via: [:get, :post]

  get '/settings', to: 'users#edit', as: 'settings'
  put '/settings', to: 'users#update'

  get '/sign_in_modal', to: 'static_pages#sign_in_modal'
  get '/about', to: 'static_pages#about'
  get '/product', to: 'static_pages#product'
  get '/how_argu_works', to: 'static_pages#how_argu_works'
  get '/team', to: 'static_pages#team'

  get '/portal', to: 'portal/portal#home'

  get '/values', to: 'documents#show', name: 'values'
  get '/policy', to: 'documents#show', name: 'policy'
  get '/privacy', to: 'documents#show', name: 'privacy'
  get '/cookies', to: 'documents#show', name: 'cookies'

  get '/activities', to: 'activities#index'
  root to: 'static_pages#home'
  get '/', to: 'static_pages#home'
end
