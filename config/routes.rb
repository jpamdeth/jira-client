Rails.application.routes.draw do
  get "github/branches"
  get "github/pulls"
  get "github/team"
  get "github/contributions", to: "github#contributions", as: :contributions
  get "jira/velocity"
  get "application/home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  resources :github, only: [ :index ]
  resources :jira, only: [ :index ]

  # Defines the root path route ("/")
  root "application#home"
end
