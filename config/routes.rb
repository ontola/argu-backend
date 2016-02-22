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

Argu::Application.routes.draw do
  concern :blog_postable do
    resources :blog_posts,
              only: [:index, :new, :create],
              path: 'posts'
  end
  concern :convertible do
    get :convert, action: :convert
    put :convert, action: :convert!
  end
  concern :destroyable do
    get :delete, action: :delete, path: :delete, as: :delete, on: :member
  end
  concern :discussable do
    resources :discussions, only: [:new]
    resources :questions, path: 'q', only: [:index, :new, :create]
    resources :motions, path: 'm', only: [:index, :new, :create]
  end
  concern :flowable do
    get :flow, controller: :flow, action: :show
  end
  concern :loggable do
    get :log, controller: :log, action: :log
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
      match action: :destroy, on: :member, as: :destroy, via: :delete, constraints: Argu::DestroyConstraint
      match action: :trash, on: :member, as: :trash, via: :delete
  end
  concern :votable do
    resources :votes, only: [:new, :create], path: 'v'
    get 'v' => 'votes#show', shallow: true, as: :show_vote
    post 'v/:for' => 'votes#create', shallow: true, as: :vote
    get 'v/:for' => 'votes#new', shallow: true
  end

  use_doorkeeper do
    controllers applications: 'oauth/applications'
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
               invitations: 'users/invitations',
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

    put 'language/:locale', to: 'users#language', on: :collection, as: :language
  end

  post 'v/:for' => 'votes#create', as: :vote
  resources :votes, only: [:destroy], path: :v

  resources :questions,
            path: 'q', except: [:index, :new, :create, :destroy],
            concerns: [:moveable, :convertible, :flowable, :trashable, :loggable] do
    resources :tags, path: 't', only: [:index]
    resources :motions, path: 'm', only: [:index, :new, :create]
  end

  resources :question_answers, path: 'qa', only: [:new, :create]

  resources :motions,
            path: 'm',
            except: [:index, :new, :create, :destroy],
            concerns: [:moveable, :convertible, :votable, :flowable, :trashable, :loggable] do
    resources :groups, only: [] do
      resources :group_responses, only: [:new, :create]
    end
    resources :tags, path: 't', only: [:index]
  end

  resources :arguments,
            path: 'a',
            except: [:index, :new, :create, :destroy],
            concerns: [:votable, :flowable, :trashable, :loggable] do
    resources :comments,
              path: 'c',
              concerns: [:trashable],
              only: [:new, :index, :show, :create, :update, :edit]
    patch 'comments' => 'comments#create'
  end

  resources :group_responses, only: [:show, :edit, :update, :destroy]
  resources :groups,
            path: 'g',
            only: [:create, :update, :edit, :destroy],
            concerns: [:destroyable] do
    resources :group_memberships, path: 'memberships', only: [:new, :create], as: :membership
  end
  resources :group_memberships, only: :destroy

  resources :pages,
            path: 'o',
            only: [:new, :create, :show, :update, :destroy],
            concerns: [:flowable, :destroyable] do
    get :transfer, on: :member
    put :transfer, on: :member, action: :transfer!
    get :settings, on: :member
    get :edit, to: 'profiles#edit', on: :member
    resources :managers, only: [:new, :create, :destroy], controller: 'pages/managers'
  end

  resources :blog_posts,
            path: 'posts',
            only: [:show, :edit, :update],
            concerns: [:trashable, :loggable]

  resources :projects,
            path: 'p',
            only: [:show, :edit, :update],
            concerns: [:blog_postable, :flowable, :discussable, :trashable, :loggable]

  resources :phases,
            only: [:show]

  resources :announcements, only: [] do
    post '/dismissals',
         to: 'static_pages#dismiss_announcement'
    get '/dismissals',
         to: 'static_pages#dismiss_announcement'
  end

  authenticate :user, ->(p) { p.profile.has_role? :staff } do
    resources :documents, only: [:edit, :update, :index, :new, :create]
    resources :notifications, only: :create
    get 'portal/settings', to: 'portal/portal#home', as: :settings_portal
    namespace :portal do
      get :settings, to: 'portal#home'
      post 'setting', to: 'portal#setting!', as: :update_setting
      resources :announcements, except: :index
      resources :forums, only: [:new, :create]
      mount Sidekiq::Web => '/sidekiq'
    end
  end

  resources :profiles, only: [:index, :update] do
    post :index, action: :index, on: :collection
    # This is to make requests POST if the user has an 'r' (which nearly all use POST)
    post ':id' => 'profiles#update', on: :collection
  end

  resources :banner_dismissals, only: :create
  get '/banner_dismissals', to: 'banner_dismissals#create'
  resources :comments, only: :show

  resources :follows, only: :create do
    delete :destroy, on: :collection
  end

  resources :shortnames, only: %i(edit update destroy)

  match '/search/' => 'search#show', as: 'search', via: [:get, :post]

  get '/settings', to: 'users#edit', as: 'settings'
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

  get '/portal', to: 'portal/portal#home'

  get '/values', to: 'documents#show', name: 'values'
  get '/policy', to: 'documents#show', name: 'policy'
  get '/privacy', to: 'documents#show', name: 'privacy'
  get '/cookies', to: 'documents#show', name: 'cookies'

  get '/activities', to: 'activities#index'

  resources :info, path: 'i', only: [:show]

  get '/quawonen_feedback', to: redirect('/quawonen')

  resources :forums,
            only: [:show, :update],
            path: '',
            concerns: [:flowable, :discussable] do
    get :discover, on: :collection, action: :discover
    get :settings, on: :member
    get :statistics, on: :member
    get :selector, on: :collection
    post :memberships, on: :collection
    resources :memberships, only: [:create, :destroy]
    resources :managers, only: [:new, :create, :destroy]
    resources :shortnames, only: [:new, :create]
    resources :projects, path: 'p', only: [:new, :create]
    resources :arguments, path: 'a', only: [:new, :create]
    resources :tags, path: 't', only: [:show, :index]
    resources :groups, path: 'g', only: [:new, :edit]
    resources :banners, except: :index
  end
  get '/forums/:id', to: redirect('/%{id}'), constraints: {format: :html}
  get 'forums/:id', to: 'forums#show'

  get '/d/modern', to: 'static_pages#modern'

  root to: 'static_pages#home'
  get '/', to: 'static_pages#home'
end
