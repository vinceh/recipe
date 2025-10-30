Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Authentication routes
  devise_for :users, path: 'api/v1/auth', controllers: {
    registrations: 'api/v1/auth/registrations',
    sessions: 'api/v1/auth/sessions'
  }, path_names: {
    sign_up: 'sign_up',
    sign_in: 'sign_in',
    sign_out: 'sign_out'
  }

  # API routes
  namespace :api do
    namespace :v1 do
      resources :recipes, only: [:index, :show] do
        member do
          post :scale
          post :favorite, to: 'favorites#create'
          delete :favorite, to: 'favorites#destroy'
        end
        resources :notes, only: [:create, :index]
      end

      resources :notes, only: [:update, :destroy]
      resources :data_references, only: [:index]

      # User favorites
      get 'users/me/favorites', to: 'favorites#index'
    end
  end

  # Admin routes
  namespace :admin do
    resources :recipes do
      member do
        post :regenerate_translations
      end
      collection do
        post :parse_text
        post :parse_url
        post :check_duplicates
        delete :bulk_delete
      end
    end

    resources :data_references do
      member do
        post :activate
        post :deactivate
      end
    end

    resources :ai_prompts do
      member do
        post :activate
        post :test
      end
    end

    resources :ingredients do
      member do
        post :refresh_nutrition
      end
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
