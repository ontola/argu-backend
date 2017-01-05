# frozen_string_literal: true
require 'argu/destroy_constraint'
require 'argu/staff_constraint'
require 'argu/forums_constraint'
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
              only: [:index, :new, :create],
              path: 'posts'
  end
  concern :commentable do
    resources :comments,
              path: 'c',
              concerns: [:trashable],
              only: [:new, :index, :show, :create, :update, :edit]
    patch 'comments' => 'comments#create'
  end
  concern :destroyable do
    get :delete, action: :delete, path: :delete, as: :delete, on: :member
  end
  concern :decisionable do
    resources :decisions, path: 'decision', except: [:destroy] do
      get :log, action: :log
    end
  end
  concern :discussable do
    resources :discussions, only: [:new]
    resources :questions, path: 'q', only: [:index, :new, :create]
    resources :motions, path: 'm', only: [:index, :new, :create]
  end
  concern :favorable do
    resources :favorites, only: [:create]
    delete 'favorites', to: 'favorites#destroy'
  end
  concern :flowable do
    get :flow, controller: :flow, action: :show
  end
  concern :moveable do
    get :move, action: :move
    put :move, action: :move!
  end
  concern :transferable do
    get :transfer, action: :transfer
    put :transfer, action: :transfer!
  end
  concern :trashable do
    put :untrash, action: :untrash, on: :member
    match '/', action: :destroy, on: :member, as: :destroy, via: :delete, constraints: Argu::DestroyConstraint
    match '/', action: :trash, on: :member, as: :trash, via: :delete
  end
  concern :votable do
    resources :votes, only: [:new, :create]
    get 'vote' => 'votes#show', as: :show_vote
  end

  use_doorkeeper do
    controllers applications: 'oauth/applications',
                tokens: 'oauth/tokens'
  end

  resources :notifications, only: [:index, :show, :update], path: 'n' do
    patch :read, on: :collection
  end
  put 'actors', to: 'actors#update'

  require 'sidekiq/web'

  get '/', to: 'static_pages#developers', constraints: {subdomain: 'developers'}
  get '/developers', to: 'static_pages#developers'

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
    post 'users', to: 'registrations#create', as: :user_registration
    delete 'users', to: 'registrations#destroy', as: nil
  end

  resources :users,
            path: 'u',
            only: [:show, :update],
            concerns: [:flowable] do
    resources :identities, only: :destroy, controller: 'users/identities'
    get :edit, to: 'profiles#edit', on: :member

    get :connect, to: 'users#connect', on: :member
    post :connect, to: 'users#connect!', on: :member

    get :setup, to: 'users#setup', on: :collection
    put :setup, to: 'users#setup!', on: :collection

    get :pages, to: 'pages#index', on: :member
    get :forums, to: 'forums#index', on: :member
    get :drafts, to: 'drafts#index', on: :member
    resources :vote_matches, only: [:show]

    put 'language/:locale', to: 'users#language', on: :collection, as: :language
  end

  resources :votes, only: [:destroy, :show, :update], path: :v, as: :vote
  resources :vote_events, only: [:show], concerns: [:votable] do
    resources :votes, only: :index
  end

  resources :vote_matches, only: [:show] do
    get :voteables, to: 'list_items#index', relationship: :voteables
    get :comparables, to: 'list_items#index', relationship: :comparables
  end

  resources :questions,
            path: 'q', except: [:index, :new, :create, :destroy],
            concerns: [:blog_postable, :moveable, :flowable, :trashable] do
    resources :tags, path: 't', only: [:index]
    resources :motions, path: 'm', only: [:index, :new, :create]
    get :search, to: 'motions#search', on: :member
  end

  resources :question_answers, path: 'qa', only: [:new, :create]
  resources :edges, only: [] do
    resources :conversions, path: 'conversion', only: [:new, :create]
    resources :grants, path: 'grants', only: [:new, :create]
  end
  resources :grants, path: 'grants', only: [:destroy]
  get 'log/:edge_id', to: 'log#show', as: :log

  resources :motions,
            path: 'm',
            except: [:index, :new, :create, :destroy],
            concerns: [:blog_postable, :moveable, :votable, :flowable, :trashable, :decisionable] do
    resources :tags, path: 't', only: [:index]
    resources :arguments, only: [:new, :create, :index]
    resources :votes, only: :index
    resources :vote_events, only: :index
  end

  resources :arguments,
            path: 'a',
            except: [:index, :new, :create, :destroy],
            concerns: [:votable, :flowable, :trashable, :commentable]

  resources :groups,
            path: 'g',
            only: [:update, :destroy],
            concerns: [:destroyable] do
    get :settings, on: :member
    resources :group_memberships, path: 'memberships', only: [:new, :create], as: :membership
  end
  resources :group_memberships, only: :destroy

  resources :pages,
            path: 'o',
            only: [:new, :create, :show, :update, :destroy],
            concerns: [:flowable, :destroyable] do
    resources :groups, path: 'g', only: [:create, :new]
    resources :group_memberships, only: :index do
      post :index, action: :index, on: :collection
    end
    resources :vote_matches, only: [:show]
    resources :sources, only: [:update], path: 's' do
      get :settings, on: :member
    end
    get :transfer, on: :member
    put :transfer, on: :member, action: :transfer!
    get :settings, on: :member
    get :edit, to: 'profiles#edit', on: :member
  end

  resources :blog_posts,
            path: 'posts',
            only: [:show, :edit, :update],
            concerns: [:trashable, :commentable]

  resources :projects,
            path: 'p',
            only: [:show, :edit, :update],
            concerns: [:blog_postable, :flowable, :discussable, :trashable]

  resources :phases,
            only: [:show, :edit, :update] do
    put :finish, to: 'phases#finish'
  end

  resources :announcements, only: [] do
    post '/dismissals',
         to: 'static_pages#dismiss_announcement'
    get '/dismissals',
        to: 'static_pages#dismiss_announcement'
  end

  resources :profiles, only: [:index, :update] do
    post :index, action: :index, on: :collection
    # This is to make requests POST if the user has an 'r' (which nearly all use POST)
    get :setup, to: 'profiles#setup', on: :collection
    put :setup, to: 'profiles#setup!', on: :collection
  end

  resources :banner_dismissals, only: :create
  get '/banner_dismissals', to: 'banner_dismissals#create'
  resources :comments, only: :show

  resources :follows, only: :create do
    delete :destroy, on: :collection
  end

  resources :shortnames, only: %i(edit update destroy)

  resources :linked_records, only: %i(show), path: :lr, concerns: [:votable] do
    get '/', action: :show, on: :collection
    resources :arguments, only: [:new, :create, :index]
    resources :votes, only: :index
    resources :vote_events, only: :index
  end

  match '/search/' => 'search#show', as: 'search', via: [:get, :post]

  get '/settings', to: 'users#settings'
  put '/settings', to: 'users#update'
  get '/c_a', to: 'users#current_actor'
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

  get '/activities', to: 'activities#index'

  resources :info, path: 'i', only: [:show]

  get '/quawonen_feedback', to: redirect('/quawonen')

  constraints(Argu::StaffConstraint) do
    resources :documents, only: [:edit, :update, :index, :new, :create]
    resources :notifications, only: :create
    namespace :portal do
      get '/', to: 'portal#home'
      get :settings, to: 'portal#home'
      post 'setting', to: 'portal#setting!', as: :update_setting
      resources :announcements, except: :index
      resources :forums, only: [:new, :create]
      resources :sources, only: [:new, :create]
      mount Sidekiq::Web => '/sidekiq'
    end
  end

  get :discover, to: 'forums#discover', as: :discover_forums
  constraints(Argu::ForumsConstraint) do
    resources :forums,
              only: [:show, :update],
              path: '',
              concerns: [:flowable, :discussable, :favorable] do
      get :settings, on: :member
      get :statistics, on: :member
      resources :shortnames, only: [:new, :create]
      resources :projects, path: 'p', only: [:new, :create]
      resources :tags, path: 't', only: [:show, :index]
      resources :banners, except: [:index, :show]
    end
  end
  resources :forums, only: [:show, :update], path: 'f', as: :canonical_forum

  get '/ns/core/:model', to: 'static_pages#context'

  get '/d/modern', to: 'static_pages#modern'

  root to: 'static_pages#home'
  get '/', to: 'static_pages#home'
  constraints(-> (req) { req.format == :json_api }) do
    get '*path', to: 'application#route_not_found'
  end
end
