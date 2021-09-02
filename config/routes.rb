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
    ontologies: :ontologies
  )
  use_linked_rails_auth(
    access_tokens: 'oauth/tokens',
    applications: 'oauth/applications',
    confirmations: 'users/confirmations',
    otp_attempts: 'users/otp_attempts',
    otp_secrets: 'users/otp_secrets',
    passwords: 'users/passwords',
    registrations: 'users/registrations',
    sessions: 'users/sessions'
  )

  get '/values', to: 'documents#show', name: 'values'
  get '/policy', to: 'documents#show', name: 'policy'
  get '/privacy', to: 'documents#show', name: 'privacy'

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
       motions questions votes vote_events budget_shops offers orders coupon_batches].map do |edgeable|
      resources edgeable, only: :index
    end
  end

  resources :grant_sets, only: :show

  constraints(Argu::StaffConstraint) do
    resources :documents, only: %i[update index create]
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

  resource :pages, path: '' do
    include_route_concerns(klass: Page)
  end
  resources :actors, only: :index
  resources :activities, only: :show
  resource :linked_records, path: 'resource', only: %i[show]

  get '(*parent_iri)/attachments', to: 'media_objects#index', defaults: {used_as: :attachment}
  post '(*parent_iri)/attachments', to: 'media_objects#create', defaults: {used_as: :attachment}
  get '(*parent_iri)/content/:version', to: 'media_object_contents#show'
  get '(*parent_iri)/feed', to: 'feed#index'
  get '(*parent_iri)/grant_sets', to: 'grant_sets#index'
  get '(*parent_iri)/granted', to: 'granted_groups#index'
  post '(*parent_iri)/o', to: 'pages#create'
  get '(*parent_iri)/o', to: 'pages#index'
  get '(*parent_iri)/permissions', to: 'grant_trees#show'
  get '(*parent_iri)/profile', to: 'menus/lists#show', id: 'profile'
  get '(*parent_iri)/search', to: 'search_results#index'
  get '(*parent_iri)/settings', to: 'menus/lists#show', id: 'settings'
  get '(*parent_iri)/statistics', to: 'statistics#show'
  get '(*parent_iri)/taggings', to: 'taggings#index', collection: :taggings
  get '(*parent_iri)/setup', to: 'actions/items#show', id: :setup
  put 'u/language', to: 'users/languages#update'

  linked_resource(Argument)
  linked_resource(Banner)
  linked_resource(BannerDismissal)
  linked_resource(BannerManagement)
  linked_resource(BlogPost)
  linked_resource(BudgetShop)
  singular_linked_resource(Cart, nested: true)
  linked_resource(CartDetail)
  singular_linked_resource(CartDetail, nested: true)
  linked_resource(Comment)
  linked_resource(Conversion)
  linked_resource(ConArgument)
  linked_resource(CouponBatch)
  linked_resource(CreativeWork)
  linked_resource(CustomAction)
  linked_resource(CustomMenuItem)
  linked_resource(Decision)
  linked_resource(DirectMessage)
  linked_resource(Discussion)
  linked_resource(EmailAddress)
  linked_resource(Export)
  linked_resource(Follow) do
    get :unsubscribe, action: :destroy, on: :member
    post '', action: :destroy, on: :member
  end
  linked_resource(Grant)
  linked_resource(GroupMembership)
  linked_resource(Group)
  linked_resource(Invite)
  linked_resource(MediaObject)
  linked_resource(Motion)
  linked_resource(Move)
  linked_resource(Offer)
  linked_resource(Order)
  linked_resource(OrderDetail)
  linked_resource(Phase)
  linked_resource(Placement)
  linked_resource(PolicyAgreement)
  linked_resource(ProArgument)
  linked_resource(Profile)
  linked_resource(Project)
  linked_resource(Publication)
  linked_resource(Question)
  linked_resource(Shortname)
  linked_resource(Submission)
  linked_resource(Survey)
  linked_resource(Term)
  linked_resource(Topic)
  singular_linked_resource(User)
  linked_resource(User)
  linked_resource(Vocabulary)
  linked_resource(Vote)
  singular_linked_resource(Vote, nested: true)
  linked_resource(VoteEvent)
  linked_resource(Widget)
  linked_resource(InterventionType)
  linked_resource(Intervention)
  linked_resource(Measure)

  ContainerNode.descendants.each do |klass|
    linked_resource(klass)
  end
  resources :container_nodes, only: %i[index]
  resources :container_nodes,
            only: %i[show],
            path: '' do
    include_route_concerns(klass: ContainerNode.descendants)
  end

  mount Sidekiq::Prometheus::Exporter => '/d/sidekiq'

  match '*path', to: 'static_pages#not_found', via: :all
end
