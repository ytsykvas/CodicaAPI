Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations' }

  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    resources :projects do
      resources :tasks do
        collection do
          get 'tasks_by_status/:status', action: 'tasks_by_status', as: 'tasks_by_status'
        end
      end
    end
  end
end
