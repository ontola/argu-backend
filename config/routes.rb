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
  concern :flowable do
    get :flow, controller: :flow, action: :show
  end
  concern :transferable do
    get :transfer, action: :transfer
    put :transfer, action: :transfer!
  end
  concern :votable do
    resources :votes, only: [:new, :create], path: 'v'
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

  resources :notifications, only: [:index, :show, :update], path: 'n' do
    patch :read, on: :collection
  end
  put 'actors', to: 'actors#update'

  require 'sidekiq/web'

  get '/', to: 'static_pages#developers', constraints: { subdomain: 'developers'}
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
  end

  post 'v/:for' => 'votes#create', as: :vote
  resources :votes, only: [:destroy], path: :v

  resources :questions,
            path: 'q', except: [:index, :new, :create],
            concerns: [:moveable, :convertible, :flowable] do
    resources :tags, path: 't', only: [:index]
  end

  resources :question_answers, path: 'qa', only: [:new, :create]

  resources :motions,
            path: 'm',
            except: [:index, :new, :create],
            concerns: [:moveable, :convertible, :votable, :flowable] do
    resources :groups, only: [] do
      resources :group_responses, path: 'responses', as: 'responses', only: [:new, :create]
    end
    resources :tags, path: 't', only: [:index]
  end

  resources :arguments,
            path: 'a',
            except: [:index, :new, :create],
            concerns: [:votable, :flowable] do
    resources :comments, path: 'c', only: [:new, :index, :show, :create, :update, :edit, :destroy]
    patch 'comments' => 'comments#create'
  end

  resources :group_responses, only: [:edit, :update, :destroy], as: :responses
  resources :groups, path: 'g', only: [:create, :update, :edit], concerns: [:destroyable] do
    resources :group_memberships, path: 'memberships', only: [:new, :create], as: :membership
  end
  resources :group_memberships, only: :destroy

  resources :pages,
            path: 'o',
            only: [:new, :create, :show, :update, :delete, :destroy] ,
            concerns: [:flowable] do
    get :delete, on: :member
    get :transfer, on: :member
    put :transfer, on: :member, action: :transfer!
    get :settings, on: :member
    get :edit, to: 'profiles#edit', on: :member
    resources :managers, only: [:new, :create, :destroy], controller: 'pages/managers'
  end

  resources :projects, path: 'p'

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
    post :index, action: :index, on: :collection
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
  put 'persist_cookie', to: 'static_pages#persist_cookie'

  # @deprecated Please use info_controller. Kept for cached searches etc. do
  get '/about', to: redirect('/i/about')
  get '/product', to: redirect('/i/product')
  get '/team', to: redirect('/i/team')
  get '/governments', to: redirect('/i/governments')
  get '/how_argu_works', to: 'static_pages#how_argu_works'
  # end

  resources :discussions, only: [:new]

  get '/portal', to: 'portal/portal#home'

  get '/values', to: 'documents#show', name: 'values'
  get '/policy', to: 'documents#show', name: 'policy'
  get '/privacy', to: 'documents#show', name: 'privacy'
  get '/cookies', to: 'documents#show', name: 'cookies'

  get '/activities', to: 'activities#index'

  resources :info, path: 'i', only: [:show]

  resources :forums,
            only: [:show, :update],
            path: '',
            concerns: [:flowable] do
    get :discover, on: :collection, action: :discover
    get :settings, on: :member
    get :statistics, on: :member
    get :selector, on: :collection
    post :memberships, on: :collection
    resources :memberships, only: [:create, :destroy]
    resources :managers, only: [:new, :create, :destroy]
    resources :questions, path: 'q', only: [:index, :new, :create]
    resources :motions, path: 'm', only: [:index, :new, :create]
    resources :arguments, path: 'a', only: [:new, :create]
    resources :tags, path: 't', only: [:show, :index]
    resources :groups, path: 'g', only: [:new, :edit]
  end
  get '/forums/:id', to: redirect('/%{id}'), constraints: {format: :html}
  get 'forums/:id', to: 'forums#show'

  get '/d/modern', to: 'static_pages#modern'

  root to: 'static_pages#home'
  get '/', to: 'static_pages#home'
end
