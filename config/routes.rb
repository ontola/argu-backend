# frozen_string_literal: true

require 'argu/destroy_constraint'
require 'argu/staff_constraint'
require 'argu/no_tenant_constraint'
require 'argu/whitelist_constraint'
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
# o: pages (organisations)
# p:
# posts: blog posts
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

Rails.application.routes.draw do
  concerns_from_enhancements

  concern :votable do
    resources :votes, only: %i[new create index]
    resource :vote, only: %i[destroy show]
  end

  constraints(Argu::WhitelistConstraint) do
    health_check_routes
  end

  use_doorkeeper do
    controllers applications: 'oauth/applications',
                tokens: 'oauth/tokens'
  end

  require 'sidekiq/web'

  get '/', to: 'static_pages#developers', constraints: {subdomain: 'developers'}
  get '/developers', to: 'static_pages#developers'
  get '/token', to: 'static_pages#token'

  devise_for :users,
             controllers: {
               registrations: 'registrations',
               sessions: 'users/sessions',
               passwords: 'users/passwords',
               unlocks: 'users/unlocks',
               omniauth_callbacks: 'omniauth_callbacks',
               confirmations: 'users/confirmations'
             }, skip: :registrations

  as :user do
    get 'users/verify', to: 'users/sessions#verify'
    get 'users/delete', to: 'registrations#delete', as: :cancel_user_registration
    get 'users/sign_up', to: 'registrations#new', as: :new_user_registration
    get 'users/wrong_email', to: 'users#wrong_email'
    post 'users', to: 'registrations#create', as: :user_registration
    delete 'users', to: 'registrations#destroy', as: nil
    put 'users/confirm', to: 'users/confirmations#confirm'
  end

  resources :users,
            path: 'u',
            only: %i[show edit] do
    resources :identities, only: :destroy, controller: 'users/identities'
    resources :email_addresses, only: %i[index new create]
    resource :follows, only: :destroy, controller: 'users/follows'

    get :connect, to: 'users/identities#connect', on: :member
    post :connect, to: 'users/identities#attach', on: :member

    get :setup, to: 'users/setup#edit', on: :collection
    put :setup, to: 'users/setup#update', on: :collection

    get :pages, to: 'users/pages#index', on: :member, path: :o
    get :forums, to: 'users/forums#index', on: :member
    get :drafts, to: 'drafts#index', on: :member

    get 'language', to: 'users/languages#edit', on: :collection, as: :edit_language
    put 'language/:locale', to: 'users/languages#update', on: :collection, as: :language
    put 'language', to: 'users/languages#update', on: :collection
    get 'settings', to: 'users#settings', as: 'settings_user', on: :collection
    put 'settings', to: 'users#update', on: :collection
    get 'settings/menus', to: 'sub_menus#index', menu_id: 'settings', on: :collection

    include_route_concerns
  end

  scope :profiles do
    get :setup, to: 'profiles#setup'
    put :setup, to: 'profiles#setup!'
  end

  get :feed, controller: :feed, action: :index
  get 'staff/feed', controller: :favorites_feed, action: :index

  resources :terms, only: %i[new create]

  resources :announcements, only: %i[show] do
    post '/dismissals',
         to: 'static_pages#dismiss_announcement'
    get '/dismissals',
        to: 'static_pages#dismiss_announcement'
  end

  resources :banner_dismissals, only: :create
  get '/banner_dismissals', to: 'banner_dismissals#create'
  get '/c_a', to: 'actors#show', as: 'current_actor'
  put 'persist_cookie', to: 'static_pages#persist_cookie'

  # @deprecated Please use info_controller. Kept for cached searches etc. do
  get '/about', to: redirect('/i/about')
  get '/product', to: redirect('/i/product')
  get '/team', to: redirect('/i/team')
  get '/governments', to: redirect('/i/governments')
  get '/how_argu_works', to: 'static_pages#how_argu_works'
  # end

  get '/values', to: 'documents#show', name: 'values'
  get '/policy', to: 'documents#show', name: 'policy'
  get '/privacy', to: 'documents#show', name: 'privacy'
  get '/cookies', to: 'documents#show', name: 'cookies'

  get '/i/about', to: 'static_pages#about'
  resources :info, path: 'i', only: [:show]

  get :discover, to: 'forums#discover', as: :discover_forums

  resources :notifications,
            only: %i[index show],
            path: 'n' do
    patch :read, on: :collection
    include_route_concerns
  end

  constraints(Argu::NoTenantConstraint) do
    root to: 'static_pages#home'

    {
      q: 'Question',
      m: 'Motion',
      a: 'Argument',
      pro: 'Argument',
      con: 'Argument',
      posts: 'BlogPost',
      c: 'Comment'
    }.each do |path, resource|
      get "#{path}/:id", to: 'redirect#show', defaults: {resource: resource.to_s}
    end
    get 'm/:id/decision/:step', to: 'redirect#show', defaults: {resource: 'Decision'}
    get ':shortname', to: 'redirect#show'
  end
  root to: 'pages#show'

  scope :apex do
    resources :menus, only: %i[show index] do
      resources :sub_menus, only: :index, path: 'menus'
    end
  end

  # @todo canonical urls of edges should redirect
  resources :edges, only: [:show] do
    %i[pro_arguments con_arguments blog_posts comments decisions discussions forums media_objects
       motions pages questions votes vote_events].map do |edgeable|
      resources edgeable, only: :index
    end
  end

  resources :email_addresses, only: [] do
    include_route_concerns
  end

  resources :follows, only: :create do
    include_route_concerns
    delete :destroy, on: :member
    get :unsubscribe, action: :destroy, on: :member
    post :unsubscribe, action: :destroy, on: :member
  end

  resources :shortnames, only: [] do
    include_route_concerns
  end

  resources :grant_sets, only: :show

  constraints(Argu::StaffConstraint) do
    resources :documents, only: %i[edit update index new create]
    resources :notifications, only: :create, path: 'n'
    namespace :portal do
      get '/', to: 'portal#home'
      get :settings, to: 'portal#home'
      post 'setting', to: 'portal#setting!', as: :update_setting
      resources :announcements, only: %i[show new create] do
        include_route_concerns
      end
      resources :users, only: [], concerns: %i[destroyable]
      mount Sidekiq::Web => '/sidekiq'
    end
  end

  constraints(Argu::WhitelistConstraint) do
    namespace :spi do
      get 'authorize', to: 'authorize#show'
      get 'current_user', to: 'users#current'
      get 'email_addresses', to: 'email_addresses#show'
      get 'find_tenant', to: 'tenant_finder#show'
      scope :oauth do
        post :token, to: 'tokens#create'
      end
    end
  end

  resources :pages, path: 'o', only: %i[new create index show]
  get :settings, to: 'pages#settings'
  get 'settings/menus', to: 'sub_menus#index', menu_id: 'settings'

  resource :pages, path: '' do
    concerns Page.route_concerns
  end

  resources :actors, only: :index
  resources :arguments, only: %i[show], path: 'a'
  %i[pro_arguments con_arguments].each do |model|
    resources model,
              path: model == :pro_arguments ? 'pro' : 'con',
              only: %i[show],
              concerns: %i[votable] do
      include_route_concerns
    end
  end
  resources :blog_posts,
            path: 'posts',
            only: %i[show] do
    include_route_concerns
  end
  resources :creative_works, only: %i[show]
  resources :comments, only: %i[show], path: 'c' do
    include_route_concerns
    resources :comments, only: %i[index new create], path: 'c'
  end
  resources :comments, only: %i[show]
  resources :direct_messages, path: :dm, only: [:create]
  resources :exports, only: [] do
    include_route_concerns
  end
  resources :favorites, only: [:create] do
    include_route_concerns
  end
  resources :grants, path: 'grants', only: %i[show new create] do
    include_route_concerns
  end
  resources :group_memberships, only: %i[show index] do
    include_route_concerns
    post :index, action: :index, on: :collection
  end
  resources :groups, path: 'g', only: %i[show create new index] do
    resources :group_memberships, only: %i[new create index]
    include_route_concerns
    get :settings, on: :member
    get 'settings/menus', to: 'sub_menus#index', menu_id: 'settings'
    resources :grants, only: %i[index]
  end
  resources :media_objects, only: :show
  resources :motions,
            path: 'm',
            only: %i[show] do
    include_route_concerns
  end
  resources :profiles, only: %i[index update show edit] do
    # This is to make requests POST if the user has an 'r' (which nearly all use POST)
    post :index, action: :index, on: :collection
  end
  resources :questions,
            path: 'q' do
    include_route_concerns
    resources :placements, only: %i[index]
  end
  resources :shortnames, only: %i[new create index]
  resources :users, path: 'u', only: %i[] do
    get :feed, controller: 'users/feed', action: :index
  end
  resources :votes, only: %i[show], as: :vote do
    include_route_concerns
  end

  %i[blogs forums open_data_portals].each do |container_node|
    resources container_node, only: %i[index new create]
  end
  resources :container_nodes,
            only: %i[show],
            path: '' do
    concerns ContainerNode.descendants.map(&:route_concerns).flatten.uniq
    resources :motions, path: :m, only: [] do
      get :search, to: 'motions#search', on: :collection
    end
    resources :grants, only: :index
    resources :linked_records,
              only: %i[show],
              path: :lr do
      include_route_concerns
    end
  end

  get '/beta', to: 'beta#show'

  get '/ns/core/:model', to: 'static_pages#context'

  get '/d/modern', to: 'static_pages#modern'

  # Mocks for calls to argu services during spec calls
  # @todo remove when front-end is detached
  if Rails.env.test?
    get 'tokens/bearer/g/:group_id', to: 'test/bearer_tokens#index'
    get 'tokens/email/g/:group_id', to: 'test/bearer_tokens#index'
    post 'tokens', to: 'test/bearer_tokens#create'
  end

  match '*path', to: 'static_pages#not_found', via: :all
end
