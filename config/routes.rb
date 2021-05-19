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
# resource:
# s: [RESERVED for search]
# t: topics
# u: users
# v: votes
# w:
# x:
# y:
# z:

Rails.application.routes.draw do
  constraints(LinkedRails::Constraints::Whitelist) do
    health_check_routes
  end

  constraints(Argu::NoTenantConstraint) do
    {
      q: Question,
      m: Motion,
      a: Argument,
      pro: Argument,
      con: Argument,
      decision: Decision,
      posts: BlogPost,
      c: Comment,
      group_memberships: GroupMembership
    }.each do |path, resource|
      get "#{path}/:id", to: 'redirect#show', defaults: {class: resource}
    end
    get ':shortname', to: 'redirect#show'

    constraints(LinkedRails::Constraints::Whitelist) do
      namespace :_public do
        namespace :spi do
          get 'find_tenant', to: 'tenant_finder#show'
          get 'tenants', to: 'tenants#index'
        end
      end
    end

    match '*path', to: 'static_pages#not_found', via: :all
  end

  use_linked_rails(
    bulk: 'spi/bulk',
    current_user: :actors,
    enum_values: :enum_values,
    forms: :forms,
    manifests: :manifests,
    vocabularies: :ontologies
  )
  use_linked_rails_auth(
    applications: 'oauth/applications',
    confirmations: 'users/confirmations',
    otp_attempts: 'users/otp_attempts',
    otp_secrets: 'users/otp_secrets',
    passwords: 'users/passwords',
    registrations: 'users/registrations',
    tokens: 'oauth/tokens'
  )

  as :user do
    get 'users/delete', to: 'users#delete'
    get 'users/wrong_email', to: 'users#wrong_email'
  end

  resources :users,
            path: 'u',
            only: %i[show edit new create] do
    resource :follows, only: :destroy, controller: 'users/follows'

    get :setup, to: 'users/setup#edit', on: :collection
    put :setup, to: 'users/setup#update', on: :collection

    get :pages, to: 'users/pages#index', on: :member, path: :o
    resources :pages, only: %i[], path: :o

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

  resources :policy_agreements, only: %i[new create]

  resources :banner_dismissals, only: :create
  get '/banner_dismissals', to: 'banner_dismissals#create'

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
  end

  root to: 'pages#show'

  # @todo canonical urls of edges should redirect
  resources :edges, only: %i[show index] do
    %i[pro_arguments con_arguments blog_posts comments decisions discussions forums media_objects
       motions questions votes vote_events budget_shops offers orders coupon_badges].map do |edgeable|
      resources edgeable, only: :index
    end
  end

  resources :email_addresses, only: %i[show index new create] do
    include_route_concerns
  end

  resources :follows, only: %i[create show] do
    include_route_concerns
    get :unsubscribe, action: :destroy, on: :member
    post '', action: :destroy, on: :member
  end

  resources :grant_sets, only: :show

  constraints(Argu::StaffConstraint) do
    resources :documents, only: %i[edit update index new create]
    resources :notifications, only: :create, path: 'n'
    namespace :portal do
      mount Sidekiq::Web => '/sidekiq'
    end
  end

  constraints(LinkedRails::Constraints::Whitelist) do
    namespace :spi do
      get 'authorize', to: 'authorize#show'
      get 'current_user', to: 'users#current'
      get 'email_addresses', to: 'email_addresses#show'
    end
  end

  resources :pages, path: 'o', only: %i[new create show]
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
              only: %i[show] do
      include_route_concerns
    end
  end
  resources :banners, only: %i[show] do
    include_route_concerns
  end
  resources :blog_posts,
            path: 'posts',
            only: %i[show] do
    include_route_concerns
  end
  resources :budget_shops, only: %i[show], path: 'budgets' do
    include_route_concerns
  end
  resources :comments, only: %i[show], path: 'c' do
    include_route_concerns
    resources :comments, only: %i[index new create], path: 'c'
  end
  resources :comments, only: %i[show]
  resources :creative_works, only: %i[show new create] do
    include_route_concerns
  end
  resources :coupon_badges, only: %i[show] do
    include_route_concerns
  end
  resources :custom_actions, only: %i[show new create] do
    include_route_concerns
  end
  resources :custom_menu_items, only: %i[index show new create] do
    include_route_concerns
  end
  resources :decisions, only: %i[show] do
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
    resources :group_memberships, only: %i[new create index]
    include_route_concerns
    resources :grants, only: %i[index new create]
  end
  resources :media_objects, only: :show do
    include_route_concerns
    resource :media_object_contents, only: :show, path: 'content/:version'
  end
  resources :motions,
            path: 'm',
            only: %i[show] do
    include_route_concerns
  end
  resource :linked_records,
           path: 'resource',
           only: %i[show] do
    include_route_concerns
  end
  resources :offers, only: %i[show] do
    include_route_concerns
  end
  resources :orders, only: %i[show] do
    include_route_concerns
  end
  resources :placements, only: :show
  resources :publications, only: :show
  resources :profiles, only: %i[index update show edit]
  resources :projects, only: %i[show] do
    include_route_concerns
  end
  resources :phases, only: %i[show] do
    include_route_concerns
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
  resources :shortnames, only: %i[show new create index] do
    include_route_concerns
  end
  resources :vocabularies, path: :vocab, only: %i[show new create index] do
    include_route_concerns

    resources :terms, only: %i[new create index] do
      include_route_concerns
    end
  end
  resources :terms, only: %i[show] do
    include_route_concerns

    resources :taggings, only: %i[index]
  end
  resources :topics,
            path: 't',
            only: %i[show] do
    include_route_concerns
  end
  resources :users, path: 'u', only: %i[] do
    get :feed, controller: 'users/feed', action: :index
  end
  resources :vote_events, only: %i[show] do
    include_route_concerns
  end
  resources :votes, only: %i[show] do
    include_route_concerns
  end
  resources :widgets, only: %i[show new create] do
    include_route_concerns
  end

  resources :intervention_types, path: 'interventie_types', only: %i[index new create show] do
    include_route_concerns
  end
  resources :interventions, path: 'interventies', only: %i[index new create show] do
    include_route_concerns
  end
  resources :measures, path: 'voorbeelden', only: %i[index new create show] do
    include_route_concerns
  end

  %i[blogs forums open_data_portals dashboards].each do |container_node|
    resources container_node, only: %i[index new create]
  end
  resources :container_nodes, only: %i[index new]
  resources :container_nodes,
            only: %i[show],
            path: '' do
    include_route_concerns(klass: ContainerNode.descendants)
  end

  mount Sidekiq::Prometheus::Exporter => '/d/sidekiq'

  match '*path', to: 'static_pages#not_found', via: :all
end
