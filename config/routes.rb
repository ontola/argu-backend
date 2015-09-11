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
    get :move, action: :move
    put :move, action: :move!
  end
  concern :convertible do
    get :convert, action: :convert
    put :convert, action: :convert!
  end
  concern :transferable do
    get :transfer, action: :transfer
    put :transfer, action: :transfer!
  end
  concern :votable do
    get 'v' => 'votes#show', shallow: true, as: :show_vote
    post 'v/:for' => 'votes#create', shallow: true, as: :vote
    get 'v/:for' => 'votes#new', shallow: true
  end
  concern :destroyable do
    get :destroy, action: :destroy, path: :destroy, as: :destroy, on: :member
    delete :destroy, action: :destroy!, on: :member
  end

  use_doorkeeper do
    controllers :applications => 'oauth/applications'
  end

  resources :notifications, only: [:index, :update], path: 'n', constraints: {subdomain: ''} do
    patch :read, on: :collection
  end
  put 'actors', to: 'actors#update', constraints: {subdomain: 'accounts'}

  require 'sidekiq/web'

  get '/', to: 'static_pages#developers', constraints: { subdomain: 'developers'}
  get '/developers', to: 'static_pages#developers', constraints: {subdomain: ''}

  devise_for :users, controllers: {
                       registrations: 'registrations',
                       sessions: 'users/sessions',
                       invitations: 'users/invitations',
                       passwords: 'users/passwords',
                       omniauth_callbacks: 'omniauth_callbacks',
                       confirmations: 'users/confirmations'
                   }, skip: :registrations, constraints: {subdomain: ''}

  as :user do
    get 'users/verify', to: 'users/sessions#verify', constraints: {subdomain: ''}
    get 'users/cancel', to: 'registrations#cancel', as: :cancel_user_registration, constraints: {subdomain: ''}
    get 'users/sign_up', to: 'registrations#new', as: :new_user_registration, constraints: {subdomain: ''}
    post 'users', to: 'registrations#create', as: :user_registration, constraints: {subdomain: ''}
    delete 'users', to: 'registrations#destroy', as: nil, constraints: {subdomain: ''}
  end

  resources :users, path: 'u', only: [:show, :update], constraints: {subdomain: ''} do
    resources :identities, only: :destroy, controller: 'users/identities'
    get :edit, to: 'profiles#edit', on: :member

    get :connect, to: 'users#connect', on: :member
    post :connect, to: 'users#connect!', on: :member

    get :setup, to: 'users#setup', on: :collection
    put :setup, to: 'users#setup!', on: :collection

    get :pages, to: 'pages#index', on: :member
    get :forums, to: 'forums#index', on: :member
  end

  post 'v/:for' => 'votes#create', as: :vote
  resources :votes, only: [:destroy], path: :v

  resources :questions, path: 'q', except: [:index], concerns: [:moveable, :convertible] do
    resources :tags, path: 't', only: [:index]
  end

  resources :motions, path: 'm', except: [:index], concerns: [:moveable, :convertible, :votable] do
    resources :groups, only: [] do
      resources :group_responses, path: 'responses', as: 'responses', only: [:new, :create]
    end
    resources :tags, path: 't', only: [:index]
  end

  resources :arguments, path: 'a', except: [:index], concerns: [:votable] do
    resources :comments, path: 'c', only: [:new, :index, :show, :create]
    patch 'comments' => 'comments#create'
  end

  resources :group_responses, only: [:edit, :update, :destroy], as: :responses
  resources :groups, path: 'g', only: [:new, :create, :edit, :update], concerns: [:destroyable] do
    resources :group_memberships, path: 'memberships', only: [:new, :create], as: :membership
  end
  resources :group_memberships, only: :destroy

  resources :pages, path: 'p', only: [:new, :create, :show, :update, :delete, :destroy] do
    get :delete, on: :member
    get :transfer, on: :member
    put :transfer, on: :member, action: :transfer!
    get :settings, on: :member
    get :edit, to: 'profiles#edit', on: :member
    resources :managers, only: [:new, :create, :destroy], controller: 'pages/managers'
  end

  authenticate :user, lambda { |u| u.staff? } do
    resources :documents, only: [:edit, :update, :index, :new, :create]
    resources :notifications, only: :create
    namespace :portal do
      get :settings, to: 'portal#settings'
      post 'settings', to: 'portal#setting!', as: :update_setting
      resources :forums, only: [:new, :create]
      mount Sidekiq::Web => '/sidekiq'
    end
  end

  resources :profiles, only: [:index, :update], constraints: {subdomain: ''} do
    post :index, action: :index, on: :collection
    # This is to make requests POST if the user has an 'r' (which nearly all use POST)
    post ':id' => 'profiles#update', on: :collection
  end

  resources :comments, only: [:show, :update, :edit, :destroy]

  resources :follows, only: :create do
    delete :destroy, on: :collection
  end

  #match '/search/' => 'search#show', as: 'search', via: [:get, :post]

  get '/settings', to: 'users#edit', as: 'settings', constraints: {subdomain: ''}
  put '/settings', to: 'users#update', constraints: {subdomain: ''}
  get '/c_a', to: 'users#current_actor', constraints: {subdomain: ''}
  put 'persist_cookie', to: 'static_pages#persist_cookie', constraints: {subdomain: ''}

  # @deprecated Please use info_controller. Kept for cached searches etc. do
  get '/about', to: redirect('/i/about'), constraints: {subdomain: ''}
  get '/product', to: redirect('/i/product'), constraints: {subdomain: ''}
  get '/team', to: redirect('/i/team'), constraints: {subdomain: ''}
  get '/governments', to: redirect('/i/governments'), constraints: {subdomain: ''}
  get '/how_argu_works', to: 'static_pages#how_argu_works', constraints: {subdomain: ''}
  # end

  get '/portal', to: 'portal/portal#home', constraints: {subdomain: ''}

  get '/values', to: 'documents#show', name: 'values', constraints: {subdomain: ''}
  get '/policy', to: 'documents#show', name: 'policy', constraints: {subdomain: ''}
  get '/privacy', to: 'documents#show', name: 'privacy', constraints: {subdomain: ''}
  get '/cookies', to: 'documents#show', name: 'cookies', constraints: {subdomain: ''}

  get '/activities', to: 'activities#index', constraints: {subdomain: ''}

  resources :info, path: 'i', only: [:show], constraints: {subdomain: ''}

  resources :forums, only: [:show, :update], path: '' do
    get :discover, on: :collection, action: :discover, constraints: {subdomain: ''}
    get :settings, on: :collection
    get :statistics, on: :collection
    get :selector, on: :collection
    post :memberships, on: :collection
    resources :memberships, only: [:create, :destroy]
    resources :managers, only: [:new, :create, :destroy]
    #resources :questions, path: 'q', only: [:index]
    #resources :motions, path: 'm', only: [:new, :create]
    resources :tags, path: 't', only: [:show, :index]
  end
  get '/forums/:id', to: redirect('/%{id}'), constraints: {format: :html}
  get 'forums/:id', to: 'forums#show'

  get '/d/modern', to: 'static_pages#modern', constraints: {subdomain: ''}

  get '/', to: 'info#show', id: 'about', constraints: {subdomain: ''}
  root to: 'forums#show'
  get '/', to: 'forums#show'
end
