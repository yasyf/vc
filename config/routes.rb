Rails.application.routes.draw do
  resource :vote, only: [:show, :create]
  root 'companies#index'

  namespace :api, constraints: { format: :json } do
    namespace :v1 do
      resources :companies do
        resources :votes
      end
    end
  end
end
