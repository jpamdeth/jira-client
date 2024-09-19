Rails.application.routes.draw do
  get "jira_filters/index"
  get "jira_filters/show"
  get "jira_issues/index"
  get "jira_issues/show"
  get "jira_issues/new"
  get "jira_issues/create"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  resources :jira_issues, only: [ :index, :show, :new, :create ]
  resources :jira_filters, only: [ :index, :show ]

  # Defines the root path route ("/")
  root "jira_issues#index"
end