####
# Routes
# a: arguments
# b:
# c: comments
# d:
# e: [might be used for 'edits']
# f: [RESERVED for forums]
# g: groups
# h: [might be used for 'history']
# i:
# j:
# k:
# l:
# m: motions
# n: notifications
# o: [RESERVED for opinions]
# p: pages
# q: questions
# r:
# s: [RESERVED for search]
# t: tags
# u: users
# v: votes
# w:
# x:
# y:
# z:

Argu::Application.routes.draw do
  concern :moveable do
    get 'move', action: 'move'
    put 'move', action: 'move!'
  end
  concern :convertible do
    get 'convert', action: 'convert'
    put 'convert', action: 'convert!'
  end
  concern :transferable do
    get 'transfer', action: 'transfer'
    put 'transfer', action: 'transfer!'
  end
  concern :votable do
    get 'v' => 'votes#show', shallow: true, as: :show_vote
    post 'v/:for' => 'votes#create', shallow: true, as: :vote
  end

  resources :notifications, only: [:index, :update], path: 'n'
  put 'actors', to: 'actors#update'

  require 'sidekiq/web'

  get '/', to: 'static_pages#developers', constraints: { subdomain: 'developers'}
  get '/developers', to: 'static_pages#developers'

  devise_for :users, :controllers => { :registrations => 'registrations', :sessions => 'users/sessions', :invitations => 'users/invitations' }, skip: :registrations

  as :user do
    get 'users/verify', to: 'users/sessions#verify'
    get 'users/cancel', to: 'registrations#cancel', as: :cancel_user_registration
    get 'users/sign_up', to: 'registrations#new', as: :new_user_registration
    post 'users', to: 'registrations#create', as: :user_registration
    delete 'users', to: 'registrations#destroy', as: nil
  end

  resources :authentications, only: [:create, :destroy]
  match 'auth/:provider/callback' => 'authentications#create', via: [:get, :post]

  resources :users, path: 'u', only: [:show, :update] do
    get :edit, to: 'profiles#edit', on: :member
    get :setup, to: 'users#setup', on: :collection
    put :setup, to: 'users#setup!', on: :collection
    get :pages, to: 'pages#index', on: :member
    get :forums, to: 'forums#index', on: :member
  end

  post 'v/:for' => 'votes#create', as: :vote

  resources :questions, path: 'q', except: [:index, :new, :create], concerns: [:moveable, :convertible] do
    resources :tags, path: 't', only: [:index]
  end

  resources :motions, path: 'm', except: [:index, :new, :create], concerns: [:moveable, :convertible, :votable] do
    resources :groups, only: [] do
      resources :group_responses, path: 'responses', as: 'responses', only: [:new, :create]
    end
    resources :tags, path: 't', only: [:index]
  end

  resources :arguments, path: 'a', except: [:index, :new, :create], concerns: [:votable] do
    resources :comments, path: 'c'
    patch 'comments' => 'comments#create'
  end

  resources :opinions, path: 'o' do
    resources :comments, path: 'c'
  end

  resources :group_responses, only: [:edit, :update, :destroy], as: :responses
  resources :group_memberships, only: :destroy

  resources :pages, path: 'p', only: [:new, :create, :show, :update, :delete, :destroy] do
    get :delete, on: :member
    get :transfer, on: :member
    put :transfer, on: :member, action: :transfer!
    get :settings, on: :member
    get :edit, to: 'profiles#edit', on: :member
    resources :managers, only: [:new, :create, :destroy], controller: 'pages/managers'
  end

  authenticate :user, lambda { |p| p.profile.has_role? :staff } do
    resources :documents, only: [:edit, :update, :index, :new, :create]
    resources :notifications, only: :create
    namespace :portal do
      get :settings, to: 'portal#settings'
      post 'settings', to: 'portal#setting!', as: :update_setting
      resources :forums, only: [:new, :create]
      mount Sidekiq::Web => '/sidekiq'
    end
  end

  resources :profiles, only: [:index, :update] do
    # This is to make requests POST if the user has an 'r' (which nearly all use POST)
    post ':id' => 'profiles#update', on: :collection
  end

  resources :comments, only: :show

  resources :follows, only: :create do
    delete :destroy, on: :collection
  end

  match '/search/' => 'search#show', as: 'search', via: [:get, :post]

  get '/settings', to: 'users#edit', as: 'settings'
  put '/settings', to: 'users#update'
  get '/c_a', to: 'users#current_actor'

  get '/sign_in_modal', to: 'static_pages#sign_in_modal'
  get '/about', to: 'static_pages#about'
  get '/product', to: 'static_pages#product'
  get '/how_argu_works', to: 'static_pages#how_argu_works'
  get '/team', to: 'static_pages#team'
  get '/governments', to: 'static_pages#governments'

  get '/portal', to: 'portal/portal#home'

  get '/values', to: 'documents#show', name: 'values'
  get '/policy', to: 'documents#show', name: 'policy'
  get '/privacy', to: 'documents#show', name: 'privacy'
  get '/cookies', to: 'documents#show', name: 'cookies'

  get '/activities', to: 'activities#index'

  resources :info, path: 'i', only: [:show]

  resources :forums, only: [:show, :update], path: '' do
    get :discover, on: :collection, action: :discover
    get :settings, on: :member
    get :statistics, on: :member
    get :selector, on: :collection
    post :memberships, on: :collection
    resources :memberships, only: [:create, :destroy]
    resources :managers, only: [:new, :create, :destroy]
    resources :questions, path: 'q', only: [:index, :new, :create]
    resources :motions, path: 'm', only: [:new, :create]
    resources :arguments, path: 'a', only: [:new, :create]
    resources :tags, path: 't', only: [:show, :index]
    resources :groups, path: 'g', only: [:new, :create, :edit, :update] do
      get 'add', on: :member
      post on: :member, action: :add!, as: ''
    end
  end
  get 'forums/:id', to: 'forums#show'

  root to: 'static_pages#home'
  get '/', to: 'static_pages#home'
end
