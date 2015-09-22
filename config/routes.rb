Rails.application.routes.draw do
  get 'ui(/:action)', controller: 'ui'

  root 'assignments#index'

  resources :assignments

  resources :users, only: :create
  get 'register', to: "users#new"
  get 'register_instructor', to: "instructors#new"
  post 'instructors', to: "instructors#create"

  get 'sign_in', to: "sessions#new"
  post 'sign_in', to: "sessions#create"
  delete 'sign_out', to: "sessions#destroy"
end
