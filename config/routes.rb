Rails.application.routes.draw do
  root 'welcome#index'

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  get '/companies', to: 'companies#index'
  resources :knowledges, only: [:index]
  resources :votes, only: [:show, :create]
  namespace :api, constraints: { format: :json } do
    namespace :v1 do
      resource :user, only: :show do
        post 'toggle_active'
      end
      resources :companies do
        resources :votes
      end
    end
  end
end
