Rails.application.routes.draw do
  get 'ui(/:action)', controller: 'ui'

  root 'courses#index'

  resources :courses do
    resources :assignments
    resources :enrollments, only: [:new, :create]
    delete 'enrollments', to: 'enrollments#destroy', as: 'enrollment'
  end

  resources :users, only: :create
  get 'register', to: "users#new"
  get 'register_instructor', to: "instructors#new"
  post 'instructors', to: "instructors#create"

  get 'sign_in', to: "sessions#new"
  post 'sign_in', to: "sessions#create"
  delete 'sign_out', to: "sessions#destroy"
end
