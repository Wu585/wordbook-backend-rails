Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resource :validation_codes,only: [:create]
      resource :session, only: [:create,:destroy]
      resource :me, only: [:show]
      resource :items
      resource :wordRecord
    end
  end
end
