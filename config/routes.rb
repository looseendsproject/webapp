# frozen_string_literal: true

Rails.application.routes.draw do

  # Working around an intermittent test bug
  # devise_for :users, skip: :all
  # as :user do
  #   get "/users/sign_up", to: "users/registrations#new", as: "new_user_registration"
  #   post "/users/sign_up", to: "users/registrations#create", as: "user_registration"
  #   get "/users/edit", to: "users/registrations#edit", as: "edit_user_registration"

  #   get "/users/sign_in", to: "users/sessions#new", as: "new_user_session"
  #   post "/users/sign_in", to: "users/sessions#create", as: "user_session"
  #   get "/users/sign_out", to: "users/sessions#destroy", as: "destroy_user_session"

  #   get "/users/password/new", to: "users/passwords#new", as: "new_user_password"
  #   post "/users/password/edit", to: "users/passwords#create", as: "edit_user_password"
  #   get "/users/password/edit", to: "users/passwords#edit", as: "user_password"
  #   put "/users/password/edit", to: "users/passwords#update"

  #   get "/users/confirmations", to: "users/confirmations#show"
  #   get "/users/confirmations/new", to: "users/confirmations#new", as: "confirmation"
  #   post "/users/confirmations", to: "users/confirmations#create"
  # end

  devise_for :users, controllers: {
    confirmations: "users/confirmations",
    passwords: "users/passwords",
    registrations: "users/registrations",
    sessions: "users/sessions",
    unlocks: "users/unlocks"
  }

  root to: "home#show"

  get "about-us", to: "home#about-us"

  get "users", to: redirect("/users/sign_up")

  resources :projects, except: :edit do
    member do
      get "edit_basics"
      get "edit_project"
      get "edit_address"
      get "edit_crafter"
    end
  end

  resource :finisher, except: :edit do
    member do
      get "edit_profile"
      get "edit_address"
      get "edit_favorites"
      get "edit_skills"
    end
  end

  namespace :manage do
    root to: "dashboards#show"
    resource :dashboard
    resources :assignments, only: %i[index edit update show destroy] do
      resources :assignment_updates, only: %i[create destroy]
    end
    resources :assignments, only: %i[destroy create]
    resources :projects do
      resources :project_notes, only: %i[create destroy]
      resources :assignments, only: [:new]
      resources :finishers, only: [:index] do
        collection do
          get "map"
        end
        get "card", on: :member
      end
      collection do
        get "finishers/search", to: "finishers#search"
      end
    end
    resources :finishers do
      collection do
        get "map"
      end
      get "card", on: :member
    end
    get 'reports/heard_about_us', to: 'reports#heard_about_us'
  end

  namespace :admin do
    root to: "dashboards#show"
    resource :dashboard
    resources :skills
    resources :products
    resources :users do
      get :assume_identity, on: :member
    end
  end
end
