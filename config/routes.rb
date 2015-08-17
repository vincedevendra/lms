Rails.application.routes.draw do
  root 'assignments#index'

  resources :assignments

  resources :users, only: :create
  get 'register', to: "users#new"
  get 'register_professor', to: "users#new_professor"
  post 'register_professor', to: "users#create_professor"

  get 'sign_in', to: "sessions#new"
  post 'sign_in', to: "sessions#create"
  get 'sign_out', to: "sessions#destroy"
end
