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

  namespace :rails do
    namespace :mailers do
      devise_for :users

      namespace :devise do
        namespace :mailer do
          get "confirmation_instructions"
          get "reset_password_instructions"
        end
      end

      get "finisher_mailer/welcome"
      get "finisher/profile_complete"
    end
  end

end
