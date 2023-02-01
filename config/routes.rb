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

  resources :projects
  resource :volunteer

  namespace :manage do
    root :to => "dashboards#show"
    resource :dashboard
    resources :assignments do
      resources :assignment_updates
    end
    resources :projects do
      resources :assignments
    end
    resources :volunteers
  end

  namespace :admin do
    root :to => "dashboards#show"
    resource :dashboard
    resources :pages
    resources :projects
    resources :skills
    resources :users
    resources :volunteers
  end

end
