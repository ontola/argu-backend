# frozen_string_literal: true

require 'argu/destroy_constraint'
require 'argu/staff_constraint'
require 'argu/forums_constraint'
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
# p: projects
# phase: phases
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
  concern :destroyable do
    delete '', action: :destroy, on: :member
    get :delete, action: :delete, path: :delete, as: :delete, on: :member
  end
  concern :decisionable do
    resources :decisions, path: 'decision', except: [:destroy], concerns: [:menuable] do
      get :log, action: :log
    end
  end
  concern :discussable do
    resources :discussions, only: [:new]
    resources :questions, path: 'q', only: %i[index new create]
    resources :motions, path: 'm', only: %i[index new create]
  end
  concern :favorable do
    resources :favorites, only: [:create]
    delete 'favorites', to: 'favorites#destroy'
  end
  concern :feedable do
    get :feed, controller: :feed, action: :show
  end
  concern :invitable do
    get :invite, controller: :invites, action: :new
  end
  concern :menuable do
    resources :menus, only: %i[index show]
  end
  concern :moveable do
    get :move, action: :shift
    put :move, action: :move
  end
  concern :trashable do
    get :delete, action: :delete, path: :delete, as: :delete, on: :member
    put :untrash, action: :untrash, on: :member
    match '/', action: :destroy, on: :member, as: :destroy, via: :delete, constraints: Argu::DestroyConstraint
    match '/', action: :trash, on: :member, as: :trash, via: :delete
  end
  concern :votable do
    resources :votes, only: %i[new create]
    get 'vote' => 'votes#show', as: :show_vote
  end

  constraints(Argu::WhitelistConstraint) do
    health_check_routes
  end

  use_doorkeeper do
    controllers applications: 'oauth/applications',
                tokens: 'oauth/tokens'
  end

  resources :notifications, only: %i[index show update], path: 'n' do
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

  resources :users,
            path: 'u',
            only: %i[show update] do
    resources :identities, only: :destroy, controller: 'users/identities'
    get :edit, to: 'profiles#edit', on: :member
    get :feed, controller: 'users/feed', action: :show

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

  get :feed, controller: :favorites_feed, action: :show

  resources :votes, only: %i[destroy update show], path: :v, as: :vote
  resources :vote_events, only: [:show], concerns: [:votable] do
    resources :votes, only: :index
  end

  resources :vote_matches, only: %i[index show create update destroy] do
    get :voteables, to: 'list_items#index', relationship: :voteables
    get :vote_comparables, to: 'list_items#index', relationship: :vote_comparables
  end

  resources :questions,
            path: 'q', except: %i[index new create],
            concerns: %i[commentable blog_postable moveable feedable trashable invitable menuable] do
    resources :media_objects, only: :index
    resources :motions, path: 'm', only: %i[index new create]
    resources :motions, path: 'motions', only: %i[index create], as: :canonical_motions
  end

  resources :question_answers, path: 'qa', only: %i[new create]
  resources :edges, only: [] do
    resources :conversions, path: 'conversion', only: %i[new create]
  end
  resources :grants, path: 'grants', only: [:destroy]
  get 'log/:edge_id', to: 'log#show', as: :log

  resources :motions,
            path: 'm',
            except: %i[index new create destroy],
            concerns: %i[commentable blog_postable moveable votable
                         feedable trashable decisionable invitable menuable] do
    resources :arguments, only: %i[new create index]
    resources :media_objects, only: :index
    resources :votes, only: :index
    resources :vote_events, only: :index
  end

  resources :arguments,
            path: 'a',
            except: %i[index new create],
            concerns: %i[votable feedable trashable commentable menuable]

  resources :groups,
            path: 'g',
            only: %i[show update],
            concerns: [:destroyable] do
    get :settings, on: :member
    resources :group_memberships, path: 'memberships', only: %i[new create], as: :membership
  end
  resources :group_memberships, only: %i[show destroy]

  resources :pages,
            path: 'o',
            only: %i[new create show update index],
            concerns: %i[feedable destroyable menuable] do
    resources :grants, path: 'grants', only: %i[new create]
    resources :groups, path: 'g', only: %i[create new]
    resources :group_memberships, only: :index do
      post :index, action: :index, on: :collection
    end
    resources :vote_matches, only: %i[index show]
    resources :sources, only: %i[update show], path: 's', concerns: %i[menuable] do
      get :settings, on: :member
    end
    get :settings, on: :member
    get :edit, to: 'profiles#edit', on: :member
  end

  resources :blog_posts,
            path: 'posts',
            only: %i[show edit update],
            concerns: %i[trashable commentable menuable]

  resources :projects,
            path: 'p',
            only: %i[show edit update],
            concerns: %i[blog_postable feedable discussable trashable menuable]

  resources :phases,
            only: %i[show edit update] do
    put :finish, to: 'phases#finish'
  end

  resources :menus, only: %i[show index]

  resources :media_objects, only: :show

  resources :announcements, only: [] do
    post '/dismissals',
         to: 'static_pages#dismiss_announcement'
    get '/dismissals',
        to: 'static_pages#dismiss_announcement'
  end

  resources :profiles, only: %i[index update] do
    post :index, action: :index, on: :collection
    # This is to make requests POST if the user has an 'r' (which nearly all use POST)
    get :setup, to: 'profiles#setup', on: :collection
    put :setup, to: 'profiles#setup!', on: :collection
  end

  resources :banner_dismissals, only: :create
  get '/banner_dismissals', to: 'banner_dismissals#create'
  resources :comments, concerns: [:trashable], only: %i[show edit update]

  resources :follows, only: :create do
    delete :destroy, on: :collection
  end

  resources :shortnames, only: %i[edit update destroy]

  resources :linked_records, only: %i[show], path: :lr, concerns: %i[votable commentable] do
    get '/', action: :show, on: :collection
    resources :arguments, only: %i[new create index]
    resources :votes, only: :index
    resources :vote_events, only: :index
  end

  match '/search/' => 'search#show', as: 'search', via: %i[get post]

  get '/settings', to: 'users#settings', as: 'settings_user'
  put '/settings', to: 'users#update'
  get '/c_a', to: 'current_actors#show'
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

  constraints(Argu::StaffConstraint) do
    resources :documents, only: %i[edit update index new create]
    resources :notifications, only: :create
    namespace :portal do
      get '/', to: 'portal#home'
      get :settings, to: 'portal#home'
      post 'setting', to: 'portal#setting!', as: :update_setting
      resources :announcements, except: :index
      resources :forums, only: %i[new create]
      resources :sources, only: %i[new create]
      mount Sidekiq::Web => '/sidekiq'
    end
  end

  get '/csrf', to: 'csrf#show'

  get :discover, to: 'forums#discover', as: :discover_forums
  constraints(Argu::ForumsConstraint) do
    resources :forums,
              only: %i[show update],
              path: '',
              concerns: %i[feedable discussable destroyable favorable invitable menuable] do
      resources :motions, path: :m, only: [] do
        get :search, to: 'motions#search', on: :collection
      end
      get :settings, on: :member
      get :statistics, on: :member
      resources :shortnames, only: %i[new create]
      resources :projects, path: 'p', only: %i[new create]
      resources :banners, except: %i[index show]
    end
  end
  resources :forums, only: %i[show update], path: 'f', as: :canonical_forum, concerns: %i[menuable]
  resources :forums, only: [], path: 'f' do
    resources :questions, path: 'questions', only: %i[index create], as: :canonical_questions
    resources :motions, path: 'motions', only: %i[index create], as: :canonical_motions
  end

  get '/ns/core/:model', to: 'static_pages#context'

  get '/d/modern', to: 'static_pages#modern'

  root to: 'static_pages#home'
  get '/', to: 'static_pages#home'

  constraints(Argu::WhitelistConstraint) do
    namespace :spi do
      get 'authorize', to: 'authorize#show'
      get 'current_user', to: 'users#current'
    end
  end

  # Mocks for calls to argu services during spec calls
  # @todo remove when front-end is detached
  if Rails.env.test?
    get 'tokens/bearer/g/:group_id', to: 'test/bearer_tokens#index'
    get 'tokens/email/g/:group_id', to: 'test/bearer_tokens#index'
    post 'tokens', to: 'test/bearer_tokens#create'
  end

  get '*path', to: 'static_pages#not_found'
end
