Rails.application.routes.draw do
  root 'welcome#index'

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  resources :knowledges, only: [:index]
  resources :companies, only: :index do
    resources :votes, only: [:show, :create, :new]
  end
  namespace :api, constraints: { format: :json } do
    namespace :v1 do
      resource :user, only: :show do
        post 'toggle_active'
      end
    end
  end
end
