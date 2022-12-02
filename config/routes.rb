Rails.application.routes.draw do
  get '/',to: 'home#index'

  namespace :api do
    namespace :v1 do
      get 'validation_codes/create'
      resources :validation_codes, only: [:create]
      resource :session, only: [:create, :destroy]
      resource :me, only: [:show]
      resources :items
      resources :word_records
    end
  end
end
