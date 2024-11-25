Rails.application.routes.draw do
  devise_for :users, controllers: {
    confirmations: 'users/confirmations',
    passwords: 'users/passwords',
    registrations: 'users/registrations',
    sessions: 'users/sessions',
    unlocks: 'users/unlocks'
  }

  root to: "home#show"

  get 'about-us', to: 'home#about-us'

  resources :projects, :except => :edit do
    member do
      get 'edit_basics'
      get 'edit_project'
      get 'edit_address'
      get 'edit_crafter'
    end
  end

  resource :finisher, :except => :edit do
    member do
      get 'edit_profile'
      get 'edit_address'
      get 'edit_favorites'
      get 'edit_skills'
    end
  end

  namespace :manage do
    root :to => "dashboards#show"
    resource :dashboard
    resources :assignments, :only => [:index, :edit, :update, :show, :destroy] do
      resources :assignment_updates, :only => [:create, :destroy]
    end
    resources :assignments, :only => [:destroy, :create]
    resources :projects do
      resources :project_notes, :only => [:create, :destroy]
      resources :assignments, :only => [:new]
      resources :finishers, :only => [:index] do
        collection do
          get 'map'
          get :search, to: 'finishers#search'
        end
        get 'card', on: :member
      end
    end
    resources :finishers do
      collection do
        get 'map'
      end
      get 'card', on: :member
    end
  end

  namespace :admin do
    root :to => "dashboards#show"
    resource :dashboard
    resources :skills
    resources :products
    resources :users do
      get :assume_identity, :on => :member
    end
  end

end
