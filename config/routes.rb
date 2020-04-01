# frozen_string_literal: true

require 'sidekiq/prometheus/exporter'

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
# t: topics
# u: users
# v: votes
# w:
# x:
# y:
# z:

Rails.application.routes.draw do
  concern :nested_actionable do
    namespace :actions do
      resources :items, path: '', only: %i[index show], collection: @scope.parent.try(:[], :controller)
    end
  end

  concern :votable do
    resources :votes, only: %i[new create index] do
      collection do
        concerns :nested_actionable
      end
    end
    resource :vote, only: %i[destroy show], path: :vote
  end

  constraints(Argu::WhitelistConstraint) do
    health_check_routes
  end

  use_doorkeeper do
    controllers applications: 'oauth/applications',
                tokens: 'oauth/tokens'
  end

  get '/ns/core', to: 'vocabularies#show'
  get '/manifest', to: 'manifests#show'

  devise_for :users,
             controllers: {
               registrations: 'registrations',
               passwords: 'users/passwords',
               unlocks: 'users/unlocks',
               confirmations: 'users/confirmations'
             }, skip: :registrations

  as :user do
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
    resources :email_addresses, only: %i[index new create] do
      collection do
        concerns :nested_actionable
      end
    end
    resource :follows, only: :destroy, controller: 'users/follows'

    get :setup, to: 'users/setup#edit', on: :collection
    put :setup, to: 'users/setup#update', on: :collection

    get :pages, to: 'users/pages#index', on: :member, path: :o
    resources :pages, only: %i[], path: :o do
      collection do
        concerns :nested_actionable
      end
    end
    get :drafts, to: 'drafts#index', on: :member

    get 'language', to: 'users/languages#edit', on: :collection, as: :edit_language
    put 'language/:locale', to: 'users/languages#update', on: :collection, as: :language
    put 'language', to: 'users/languages#update', on: :collection
    get 'profile', to: 'menus#show', id: 'profile'
    get 'profile/menus', to: 'sub_menus#index', menu_id: 'profile'

    include_route_concerns
  end

  scope :profiles do
    get :setup, to: 'profiles#setup'
  end

  get :feed, controller: :feed, action: :index

  resources :terms, only: %i[new create]

  resources :banner_dismissals, only: :create
  get '/banner_dismissals', to: 'banner_dismissals#create'
  get '/c_a', to: 'actors#show', as: 'current_actor'

  # @deprecated Please use info_controller. Kept for cached searches etc. do
  get '/about', to: redirect('/i/about')
  get '/product', to: redirect('/i/product')
  get '/team', to: redirect('/i/team')
  get '/governments', to: redirect('/i/governments')
  # end

  get '/values', to: 'documents#show', name: 'values'
  get '/policy', to: 'documents#show', name: 'policy'
  get '/privacy', to: 'documents#show', name: 'privacy'

  resources :info, path: 'i', only: [:show]

  resources :notifications,
            only: %i[index show],
            path: 'n' do
    patch :read, on: :collection
    include_route_concerns
    collection do
      concerns :nested_actionable
    end
  end

  constraints(Argu::NoTenantConstraint) do
    {
      q: Question,
      m: Motion,
      a: Argument,
      pro: Argument,
      con: Argument,
      posts: BlogPost,
      c: Comment,
      group_memberships: GroupMembership
    }.each do |path, resource|
      get "#{path}/:id", to: 'redirect#show', defaults: {class: resource}
    end
    get 'm/:parent_id/decision/:id', to: 'redirect#show', defaults: {class: Decision}
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

  resources :email_addresses, only: %i[show] do
    include_route_concerns
  end

  resources :follows, only: %i[create show] do
    include_route_concerns
    get :unsubscribe, action: :destroy, on: :member
    post '', action: :destroy, on: :member
  end

  resources :shortnames, only: [] do
    include_route_concerns
  end

  resources :grant_sets, only: :show

  constraints(Argu::StaffConstraint) do
    resources :documents, only: %i[edit update index new create]
    resources :notifications, only: :create, path: 'n'
    namespace :portal do
      mount Sidekiq::Web => '/sidekiq'
    end
  end

  constraints(Argu::WhitelistConstraint) do
    namespace :_public do
      namespace :spi do
        get 'find_tenant', to: 'tenant_finder#show'
        get 'tenants', to: 'tenants#index'
      end
    end
    namespace :spi do
      get 'authorize', to: 'authorize#show'
      get 'current_user', to: 'users#current'
      get 'email_addresses', to: 'email_addresses#show'
    end
  end

  resources :pages, path: 'o', only: %i[new create index show] do
    collection do
      concerns :nested_actionable
    end
  end
  get :settings, to: 'pages#settings'
  get 'settings/menus', to: 'sub_menus#index', menu_id: 'settings'

  resource :pages, path: '' do
    include_route_concerns(klass: Page)
  end

  resources :actors, only: :index
  resources :activities, only: :show
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
  resources :comments, only: %i[show], path: 'c' do
    include_route_concerns
    resources :comments, only: %i[index new create], path: 'c' do
      collection do
        concerns :nested_actionable
      end
    end
  end
  resources :comments, only: %i[show]
  resources :creative_works, only: %i[show new create] do
    include_route_concerns
  end
  resources :custom_actions, only: %i[show new create] do
    include_route_concerns
  end
  resources :custom_menu_items, only: %i[index show new create] do
    include_route_concerns
  end
  resources :direct_messages, path: :dm, only: [:create]
  resources :exports, only: [] do
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
    collection do
      concerns :nested_actionable
    end
    resources :group_memberships, only: %i[new create index] do
      collection do
        concerns :nested_actionable
      end
    end
    include_route_concerns
    get :settings, on: :member
    get 'settings/menus', to: 'sub_menus#index', menu_id: 'settings'
    resources :grants, only: %i[index new create] do
      collection do
        concerns :nested_actionable
      end
    end
  end
  resources :media_objects, only: :show do
    resource :media_object_contents, only: :show, path: 'content/:version'
  end
  resources :motions,
            path: 'm',
            only: %i[show] do
    include_route_concerns
  end
  resources :placements, only: :show
  resources :publications, only: :show
  resources :profiles, only: %i[index update show edit] do
    # This is to make requests POST if the user has an 'r' (which nearly all use POST)
    post :index, action: :index, on: :collection
  end
  resources :questions,
            path: 'q' do
    include_route_concerns
  end
  resources :surveys, only: %i[show] do
    include_route_concerns
    resource :submission, only: %i[create] do
      include_route_concerns
    end
  end
  resources :projects, only: %i[show] do
    include_route_concerns
  end
  resources :phases, only: %i[show] do
    include_route_concerns
  end
  resources :shortnames, only: %i[new create index] do
    collection do
      concerns :nested_actionable
    end
  end
  resources :topics,
            path: 't',
            only: %i[show] do
    include_route_concerns
  end
  resources :users, path: 'u', only: %i[] do
    get :feed, controller: 'users/feed', action: :index
  end
  resources :votes, only: %i[show], as: :vote do
    include_route_concerns
  end
  resources :widgets, only: %i[show new create] do
    include_route_concerns
  end

  {risks: 'gevaren', intervention_types: 'interventie_types', measure_types: 'measure_types',
   categories: 'categories', incidents: 'incidents', scenarios: 'scenarios'}.each do |key, value|
    resources key, path: value, only: %i[index new create show] do
      include_route_concerns
      collection do
        concerns :nested_actionable
      end
    end
  end
  resources :interventions, path: 'interventies', only: %i[index new create show] do
    include_route_concerns
  end
  resources :measures, path: 'voorbeelden', only: %i[index new create show] do
    include_route_concerns
  end
  resources :employments, only: %i[index new create show] do
    include_route_concerns
    collection do
      concerns :nested_actionable
    end
  end
  resources :employment_moderations, path: 'moderation', only: %i[index show new] do
    include_route_concerns
    collection do
      concerns :nested_actionable
    end
  end

  %i[blogs forums open_data_portals dashboards].each do |container_node|
    resources container_node, only: %i[index new create]
  end
  resources :container_nodes, only: %i[index new] do
    collection do
      concerns :nested_actionable
    end
  end
  resources :container_nodes,
            only: %i[show],
            path: '' do
    include_route_concerns(klass: ContainerNode.descendants)
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

  mount Sidekiq::Prometheus::Exporter => '/d/sidekiq'

  match '*path', to: 'static_pages#not_found', via: :all
end
