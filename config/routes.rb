# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: :rails_admin
  devise_for(
    :users,
    skip: %i[sessions registrations confirmations passwords]
  )

  devise_scope :user do
    post '/users/sign_in', to: 'users/sessions#create', as: :session
    post '/users/sign_up', to: 'users/registrations#create', as: :registration
    delete '/users/sign_out', to: 'users/sessions#destroy', as: :destroy_user_session
    get '/users/confirmation', to: 'users/confirmations#show', as: :confirmation
    post '/users/confirmation', to: 'users/confirmations#create'
    post '/users/password', to: 'users/passwords#create', as: :password
    get '/users/password/edit', to: 'users/passwords#edit', as: :edit_password
    put '/users/password', to: 'users/passwords#update'
  end

  root 'static#index'
  get '/styleguide', to: 'static#styleguide'
  get '/profile', to: 'profiles#select_type', as: :profile_type
  post '/profile', to: 'profiles#redirect_to_profile_form', as: :profile_form
  get '/profile/preview', to: 'profiles#preview', as: :profile_preview
  get(
    '/profile/:type',
    to:          'profiles#edit',
    constraints: { type: /(#{User::PROFILES.keys.join('|')})?/ },
    as:          :edit_profile
  )
  post(
    '/profile/:type/validate',
    to:          'profiles#validate',
    constraints: { type: /(#{User::PROFILES.keys.join('|')})?/ },
    as:          :validate_profile
  )
  post(
    '/profile/:type',
    to:          'profiles#update',
    constraints: { type: /(#{User::PROFILES.keys.join('|')})?/ }
  )
  get '/profile/:id', to: 'profiles#show', as: :profile
  post '/profile/update-password', to: 'profiles#update_password', as: :update_password

  resources :rooms, path: 'listings' do
    get 'my', on: :collection, as: :my
    post 'validate', on: :new
    put 'validate', on: :member
    patch 'validate', on: :member
    post 'hide', on: :member
    post 'unhide', on: :member
  end

  resources :conversations, only: %i[index show] do
    resources :messages, only: %i[create]
    get 'with/(:user_id)', on: :collection, action: :find_or_create, as: :find_or_create
    post 'ignore', on: :member
    post 'unignore', on: :member
    get 'invite-social-worker', on: :member, as: :invite_social_worker
    get 'report', on: :member, as: :report
  end

  resources :surveys, only: %i[index] do
    get 'fill/:user_id', on: :collection, to: 'surveys#fill', as: :fill
    get 'details/:user_id', on: :collection, to: 'surveys#details', as: :details
    post 'save/:user_id', on: :collection, to: 'surveys#save', as: :save
  end

  authenticate :user, ->(u) { u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end
end
