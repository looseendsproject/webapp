# frozen_string_literal: true

Rails.application.routes.draw do

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

  resources :message, only: :show

  namespace :manage do
    mount MissionControl::Jobs::Engine, at: "/jobs"

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
    get "reports/heard_about_us", to: "reports#heard_about_us"
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
