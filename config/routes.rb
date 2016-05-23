Rails.application.routes.draw do
  root 'welcome#index'
  namespace :api, constraints: { format: :json } do
    namespace :v1 do
      resources :companies do
        resources :votes
      end
    end
  end
end
