# frozen_string_literal: true

# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

require 'sidekiq/web'

Rails.application.routes.draw do
  use_doorkeeper do
    skip_controllers :applications, :token_info, :authorizations
  end
  get 'google/config', to: 'google_sessions#configuration'
  post 'google/sign_in', to: 'google_sessions#create'
  get 'users/whoami'
  get 'cost_center/index'
  get 'cost_center/create'
  get 'cost_center/update'
  get 'cost_center/destroy'
  get 'seats/update'
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?
  get 'token' => 'tokens#show', as: :token
  get 'up' => 'rails/health#show', as: :rails_health_check

  resources :captcha, only: :create do
    get 'v2/media', to: 'captcha#media', on: :collection, as: :media
  end

  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  mount MissionControl::Jobs::Engine, at: '/jobs'

  authenticate :user, ->(u) { u.superadmin } do
    mount Sidekiq::Web => '/sidekiq'
  end

  # default slug required to make Mission Control Jobs work

  namespace :system do
    put '/tasks/:id', to: 'tasks#update'
    post '/tasks/:id/stats', to: 'tasks#create_stats'
  end

  scope ':slug', constraints: { slug: Wedding::SLUG_REGEX }, defaults: { slug: :default } do
    devise_for :users, skip: %i[registration session confirmation password]
    devise_scope :user do
      post 'users', to: 'users/registrations#create'

      post '/users/sign_in', to: 'users/sessions#create'
      delete '/users/sign_out', to: 'users/sessions#destroy'

      get '/users/confirmation', to: 'users/confirmations#show', as: :confirmation
      put '/users/password', to: 'users/passwords#update'
      post '/users/password', to: 'users/passwords#create'
    end

    resources :users, only: [:update] do
      get :whoami, on: :collection
    end
    resources :memberships, only: %i[index create destroy] do
      get :accept, on: :member
    end

    get 'planner', to: 'planner#index'
    %w[tasks vendors].each do |entity|
      post "planner/#{entity}/:record_id/documents", to: 'planner_documents#create', defaults: { entity: }
      get "planner/#{entity}/:record_id/documents/:id", to: 'planner_documents#show', defaults: { entity: }
      delete "planner/#{entity}/:record_id/documents/:id", to: 'planner_documents#destroy', defaults: { entity: }
    end
    post 'planner/:entity', to: 'planner#create'
    patch 'planner/:entity/:id', to: 'planner#update'
    delete 'planner/:entity/:id', to: 'planner#destroy'

    resources :tasks, only: %i[index create update destroy]
    resources :locations, only: %i[index create destroy]
    resources :menu_options, only: %i[index create update destroy]

    resources :groups, only: %i[index create update destroy] do
      post 'affinities/reset', to: 'affinities#reset', on: :collection
      resources :affinities, only: %i[index] do
        put :bulk_update, on: :collection
        get :default, on: :collection
      end
    end

    resources :guests, only: %i[index create update destroy] do
      post :bulk_update, on: :collection
      post :import, on: :collection
    end
    resources :expenses, only: %i[index create update destroy] do
      get :summary, on: :collection
    end

    resource :website, only: %i[show update] do
      get :validate_dns, on: :collection
    end

    resources :tables_arrangements, only: %i[index show] do
      put :move, on: :member
      put :pin, on: :member
      post :optimize, on: :member
      post :reset, on: :member

      resources :tables, only: %i[create update]
    end
    resources :table_types, only: %i[index create update destroy]

    resources :summary, only: :index
    resources :invitations, only: %i[show index create update destroy] do
      post :email, on: :collection
      post :envelopes_document, on: :collection
    end
    resources :payments, only: %i[create update destroy]
    resource :settings, only: %i[show update] do
      post :invitation_background, to: 'settings#set_invitation_background'
      get :fonts
      post :request_wedding_deletion, to: 'settings#request_wedding_deletion'
      get :confirm_wedding_deletion, to: 'settings#confirm_wedding_deletion'
    end
    resources :cost_centers, only: %i[index create update destroy] do
      get :stats, on: :collection
    end

    resources :buses, only: %i[index create destroy] do
      get :stats, on: :collection
    end

    scope :engine do
      post :heartbeat, to: 'engine#heartbeat'
    end

    scope :reports do
      get ':id', to: 'reports#show'
    end

    root to: redirect('/%{slug}')
  end
end
