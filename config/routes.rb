Rails.application.routes.draw do
  devise_for :users

  # Defines the root path route ("/")
  root to: "home#index"

  resources :projects

  namespace :manage do
    resources :assignments do
      resources :assignment_updates
    end
    resources :projects
    resources :volunteers do
      resources :assignments
    end
  end

  namespace :admin do
    resources :projects
    resources :skills
    resources :users
    resources :volunteers
  end

  get '*page_path', to: 'pages#show'

end
