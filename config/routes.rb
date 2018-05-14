# frozen_string_literal: true

require 'argu/destroy_constraint'
require 'argu/staff_constraint'
require 'argu/pages_constraint'
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
  concern :actionable do
    resources :actions, only: %i[index show]
  end
  concern :argumentable do
    resources :arguments, only: %i[new create]
    resources :pro_arguments, only: %i[new create index], path: 'pros', defaults: {pro: 'pro'}
    resources :con_arguments, only: %i[new create index], path: 'cons', defaults: {pro: 'con'}
  end
  concern :blog_postable do
    resources :blog_posts,
              only: %i[index new create],
              path: 'posts'
  end
  concern :commentable do
    resources :comments,
              path: 'c',
              only: %i[new index show create]
    patch 'comments' => 'comments#create'
  end
  concern :contactable do
    resources :direct_messages, path: :dm, only: [:new]
  end
  concern :destroyable do
    delete '', action: :destroy, on: :member, as: :destroy
    get :delete, action: :delete, path: :delete, as: :delete, on: :member
  end
  concern :decisionable do
    resources :decisions, path: 'decision', except: [:destroy], concerns: [:menuable] do
      get :log, action: :log
    end
  end
  concern :discussable do
    resources :discussions, only: %i[index new]
    resources :questions, path: 'q', only: %i[index new create]
    resources :motions, path: 'm', only: %i[index new create]
  end
  concern :exportable do
    resources :exports, only: %i[index create]
  end
  concern :favorable do
    resources :favorites, only: [:create]
    delete 'favorites', to: 'favorites#destroy'
  end
  concern :feedable do
    get :feed, controller: :feed, action: :index
  end
  concern :invitable do
    get :invite, controller: :invites, action: :new
  end
  concern :loggable do
    resource :log, only: %i[show], on: :member
  end
  concern :menuable do
    resources :menus, only: %i[index show]
  end
  concern :moveable do
    get :move, action: :shift, on: :member
    put :move, action: :move, on: :member
  end
  concern :statable do
    get :statistics, to: 'statistics#show'
  end
  concern :trashable do
    get :delete, action: :delete, as: :delete, on: :member
    delete '', action: :destroy, on: :member, as: :destroy, constraints: Argu::DestroyConstraint

    get :trash, action: :bin, as: :trash, on: :member
    delete '', action: :trash, on: :member

    get :untrash, action: :unbin, as: :untrash, on: :member
    put :untrash, action: :untrash, on: :member
  end
  concern :votable do
    resources :votes, only: %i[new create index]
    resource :vote, only: %i[destroy show]
  end
  concern :vote_eventable do
    resources :vote_events, only: %i[index show], concerns: %i[votable]
  end

  constraints(Argu::WhitelistConstraint) do
    health_check_routes
  end

  use_doorkeeper do
    controllers applications: 'oauth/applications',
                tokens: 'oauth/tokens'
  end

  resources :notifications,
            concerns: %i[actionable],
            only: %i[index show update],
            path: 'n' do
    patch :read, on: :collection
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
               omniauth_callbacks: 'omniauth_callbacks',
               confirmations: 'users/confirmations'
             }, skip: :registrations

  as :user do
    get 'users/verify', to: 'users/sessions#verify'
    get 'users/cancel', to: 'registrations#cancel', as: :cancel_user_registration
    get 'users/sign_up', to: 'registrations#new', as: :new_user_registration
    get 'users/wrong_email', to: 'users#wrong_email'
    post 'users', to: 'registrations#create', as: :user_registration
    delete 'users', to: 'registrations#destroy', as: nil
    put 'users/confirm', to: 'users/confirmations#confirm'
  end

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

  resources :users,
            path: 'u',
            only: %i[show update] do
    resources :identities, only: :destroy, controller: 'users/identities'
    get :edit, to: 'profiles#edit', on: :member
    get :feed, controller: 'users/feed', action: :index

    get :connect, to: 'users/identities#connect', on: :member
    post :connect, to: 'users/identities#connect!', on: :member

    get :setup, to: 'users#setup', on: :collection
    put :setup, to: 'users#setup!', on: :collection

    get :pages, to: 'users/pages#index', on: :member
    get :forums, to: 'forums#index', on: :member
    get :drafts, to: 'drafts#index', on: :member
    resources :vote_matches, only: %i[index show]

    put 'language/:locale', to: 'users#language', on: :collection, as: :language
  end

  get :feed, controller: :favorites_feed, action: :index

  resources :vote_matches, only: %i[index show create update destroy] do
    get :voteables, to: 'list_items#index', relationship: :voteables
    get :vote_comparables, to: 'list_items#index', relationship: :vote_comparables
  end

  resources :edges, only: [:show] do
    get :statistics, to: 'statistics#show'
    resources :exports, only: %i[index create]
    resources :conversions, path: 'conversion', only: %i[new create]
    resource :grant_tree, only: %i[show], path: 'permissions'
    %i[pro_arguments con_arguments blog_posts comments decisions discussions forums media_objects
       motions pages questions votes vote_events vote_matches].map do |edgeable|
      resources edgeable, only: :index
    end
  end
  resources :exports, only: [], concerns: %i[destroyable]
  resources :grants, path: 'grants', only: [:destroy]

  resources :direct_messages, path: :dm, only: [:create]

  resources :favorites, only: [:create]

  resources :groups,
            path: 'g',
            only: %i[show update],
            concerns: [:destroyable] do
    get :settings, on: :member
    resources :group_memberships, path: 'memberships', only: %i[new create]
  end
  resources :group_memberships, only: %i[show destroy]

  get '/o/find', to: 'organizations_finder#show'

  resources :menus, only: %i[show index]

  resources :media_objects, only: :show

  resources :announcements, only: %i[show] do
    post '/dismissals',
         to: 'static_pages#dismiss_announcement'
    get '/dismissals',
        to: 'static_pages#dismiss_announcement'
  end
  resources :banners, except: %i[index show new create]

  resources :profiles, only: %i[index update] do
    post :index, action: :index, on: :collection
    # This is to make requests POST if the user has an 'r' (which nearly all use POST)
    get :setup, to: 'profiles#setup', on: :collection
    put :setup, to: 'profiles#setup!', on: :collection
  end

  resources :banner_dismissals, only: :create
  get '/banner_dismissals', to: 'banner_dismissals#create'

  resources :follows, only: :create do
    delete :destroy, on: :member
    get :unsubscribe, action: :destroy, on: :member
    post :unsubscribe, action: :destroy, on: :member
  end

  resources :shortnames, only: %i[edit update destroy]

  resources :grant_sets, only: :show

  match '/search/' => 'search#show', as: 'search', via: %i[get post]

  get '/settings', to: 'users#settings', as: 'settings_user'
  put '/settings', to: 'users#update'
  get '/c_a', to: 'current_actors#show', as: 'current_actor'
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

  get '/quawonen_feedback', to: redirect('/quawonen')

  get :discover, to: 'forums#discover', as: :discover_forums

  constraints(Argu::StaffConstraint) do
    resources :documents, only: %i[edit update index new create]
    resources :notifications, only: :create
    namespace :portal do
      get '/', to: 'portal#home'
      get :settings, to: 'portal#home'
      post 'setting', to: 'portal#setting!', as: :update_setting
      resources :announcements, except: :index
      resources :forums, only: %i[new create]
      resources :users, only: [], concerns: %i[destroyable]
      mount Sidekiq::Web => '/sidekiq'
    end
  end

  get '/csrf', to: 'csrf#show'

  get '/ns/core/:model', to: 'static_pages#context'

  get '/d/modern', to: 'static_pages#modern'

  root to: 'static_pages#home'
  get '/', to: 'static_pages#home'

  constraints(Argu::WhitelistConstraint) do
    namespace :spi do
      get 'authorize', to: 'authorize#show'
      get 'current_user', to: 'users#current'
      scope :oauth do
        post :token, to: 'tokens#create'
      end
    end
  end

  resources :pages, path: 'o', only: %i[new create index]

  constraints(Argu::PagesConstraint) do
    resources :pages,
              path: '',
              only: %i[show update],
              concerns: %i[feedable destroyable menuable statable exportable] do
      resources :discussions, only: %i[index]
      resources :grants, path: 'grants', only: %i[new create]
      resources :group_memberships, only: :index do
        post :index, action: :index, on: :collection
      end
      resources :groups, path: 'g', only: %i[create new]
      resources :vote_matches, only: %i[index show]
      get :settings, on: :member
      get :edit, to: 'profiles#edit', on: :member
    end

    scope ':root_id' do
      resources :questions,
                path: 'q', except: %i[index new create],
                concerns: %i[actionable commentable blog_postable moveable feedable exportable
                             trashable invitable menuable contactable statable loggable] do
        resources :media_objects, only: :index
        resources :motions, path: 'm', only: %i[index new create]
      end

      resources :motions,
                path: 'm',
                except: %i[index new create destroy],
                concerns: %i[actionable argumentable commentable blog_postable moveable vote_eventable contactable
                             feedable trashable decisionable invitable menuable statable exportable loggable] do
        resources :media_objects, only: :index
      end
      resources :arguments, only: %i[show], path: 'a'
      %i[pro_arguments con_arguments].each do |model|
        resources model,
                  path: model == :pro_arguments ? 'pro' : 'con',
                  except: %i[index new create],
                  concerns: %i[actionable votable feedable trashable commentable menuable contactable statable loggable]
      end
      resources :votes, only: %i[destroy update show], as: :vote
      resources :blog_posts,
                path: 'posts',
                only: %i[show edit update],
                concerns: %i[trashable commentable menuable statable loggable]
      resources :comments, concerns: %i[actionable trashable loggable], only: %i[show edit update], path: 'c'
      resources :comments, only: %i[show]

      resources :forums,
                only: %i[show update],
                path: '',
                concerns: %i[feedable discussable destroyable favorable invitable menuable
                             moveable statable exportable] do
        resources :motions, path: :m, only: [] do
          get :search, to: 'motions#search', on: :collection
        end
        get :settings, on: :member
        resources :shortnames, only: %i[new create]
        resources :banners, only: %i[new create]
        resources :linked_records,
                  only: %i[show],
                  path: :lr,
                  concerns: %i[argumentable commentable vote_eventable]
      end
    end
  end

  # Mocks for calls to argu services during spec calls
  # @todo remove when front-end is detached
  if Rails.env.test?
    get 'tokens/bearer/g/:group_id', to: 'test/bearer_tokens#index'
    get 'tokens/email/g/:group_id', to: 'test/bearer_tokens#index'
    post 'tokens', to: 'test/bearer_tokens#create'
  end

  match '*path', to: 'static_pages#not_found', via: :all
end
