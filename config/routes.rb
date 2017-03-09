require 'sidekiq/web'

class TeamConstraint
  def initialize
    @teams = Team::ALL + [nil]
  end

  def matches?(request)
    @teams.include? request.params[:team]
  end
end

Rails.application.routes.draw do
  get 'stats/show'

  root 'welcome#index'

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  get 'team', to: 'welcome#select_team'
  get 'feedback', to: 'welcome#send_slack_feedback'

  scope "(:team)", constraints: TeamConstraint.new do
    resources :knowledges, only: [:index]
    resources :stats, only: [:index]
    get 'all', to: 'companies#all'
    get 'voting', to: 'companies#voting'
    resources :companies, only: [:index, :show] do
      resources :votes, only: [:show, :create, :new]
    end
  end

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :events, only: [:show, :update] do
        member do
          post 'invalidate'
        end
      end

      scope "(:team)", constraints: TeamConstraint.new do
        resources :votes, only: [:index, :show]
        resources :companies, only: [:index, :show] do
          member do
            get 'voting_status'
            post 'allocate'
            post 'reject'
            post 'invalidate_crunchbase'
          end
          collection do
            get 'search'
          end
        end
      end
      resource :user, only: :show do
        get 'token'
        post 'toggle_active'
        post 'set_team'
      end
    end
  end

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: '/emails'
  end

  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web, at: '/sidekiq'
  end
end
