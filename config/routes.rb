require 'action_dispatch/middleware/static'
Rails.application.routes.draw do
  # get '/',to: 'home#index'
  root 'home#index'
  
  namespace :api do
    namespace :v1 do
      resources :validation_codes, only: [:create]
      resource :session, only: [:create, :destroy]
      resource :me, only: [:show]
      resources :items do
        collection do
          get :balance
          get :summary
        end
      end
      resources :tags
      resources :words
    end
  end
end
