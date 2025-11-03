# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, controllers: {
    confirmations: "users/confirmations",
    passwords: "users/passwords",
    registrations: "users/registrations",
    sessions: "users/sessions",
    unlocks: "users/unlocks"
  }
  devise_scope :user do
    get "magic_link", to: "users/sessions#magic_link", as: :magic_link
    post "resend_link", to: "users/sessions#resend_link"
  end

  root to: "home#show"

  get "test_flash_messages", to: "application#test_flash_messages"

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

  get "/assignment/:id/check_in", to: "assignments#check_in", as: :check_in
  post "/assignment/:id/check_in", to: "assignments#record_check_in"
  get "/thank_you", to: "assignments#thank_you", as: :thank_you

  resources :message, only: :show

  namespace :manage do
    mount MissionControl::Jobs::Engine, at: "/jobs"

    root to: "dashboards#show"
    resource :dashboard
    resources :assignments, only: %i[index edit update show destroy] do
      resources :assignment_updates, only: %i[create destroy]
    end
    resources :assignments, only: %i[destroy create]
    resources :notes, only: %i[index create destroy]

    resources :projects do
      resources :notes, only: %i[create destroy]
      resources :assignments, only: [:new]
      resources :finishers, only: [:index] do
        collection do
          get "map"
        end
        get "card", on: :member
      end
      collection do
        get "finishers/search", to: "finishers#search"
        post "saved_view/remove", to: "projects#remove_saved_view"
      end
      resources :users, only: [:index], controller: "project_users" do
        member do
          post :assign_owner
        end
      end
    end

    resources :users, only: [:index, :new, :create]

    resources :finishers do
      collection do
        get "map"
      end
      get "card", on: :member
    end
    resources :job_logs, only: [:show]
    resources :inbound_emails

    namespace :reports do
      get "/", action: :index
      get "heard_about_us"
      get "active_projects_by_status"
      get "new_projects_by_month"
      get "new_finishers_by_month"
      get "project_countries"
      get "finisher_countries"
      get "project_counts"
    end
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
