Argu::Application.routes.draw do

  put 'actors', to: 'actors#update'

  require 'sidekiq/web'

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

  resources :questions, except: [:index, :new, :create]

  resources :motions, except: [:index, :new, :create] do
    post 'vote/:for'      => 'votes/motions#create',   as: 'vote'
    delete 'vote'         => 'votes/motions#destroy',  as: 'vote_delete'
  end

  resources :arguments, except: [:index, :new, :create] do
    resources :comments

    post   'vote' => 'votes/arguments#create'
    delete 'vote' => 'votes/arguments#destroy'
  end

  resources :opinions do
    resources :comments
  end

  resources :forums, except: [:index, :edit] do
    get :settings, on: :member
    get :statistics, on: :member
    resources :memberships, only: [:create, :destroy]
    resources :questions, only: [:index, :new, :create]
    resources :motions, only: [:new, :create]
    resources :arguments, only: [:new, :create]
    resources :tags, only: [:show]
  end

  resources :pages, only: [:show, :update] do
    get :settings, on: :member
  end

  authenticate :user, lambda { |p| p.profile.has_role? :staff } do
    resources :documents, only: [:edit, :update, :index, :new, :create]
    namespace :portal do
      resources :pages, only: [:show, :new, :create, :destroy]
      resources :forums, only: [:new, :create]
      mount Sidekiq::Web => '/sidekiq'
    end
  end

  resources :profiles

  match '/search/' => 'search#show', as: 'search', via: [:get, :post]

  get '/settings', to: 'users#edit', as: 'settings'
  put '/settings', to: 'users#update'

  get '/sign_in_modal', to: 'static_pages#sign_in_modal'
  get '/about', to: 'static_pages#about'

  get '/portal', to: 'portal/portal#home'

  get '/values', to: 'documents#show', name: 'values'
  get '/policy', to: 'documents#show', name: 'policy'
  get '/privacy', to: 'documents#show', name: 'privacy'
  get '/cookies', to: 'documents#show', name: 'cookies'

  root to: 'static_pages#home'
  get '/', to: 'static_pages#home'
end
