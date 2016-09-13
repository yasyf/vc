class TeamConstraint
  def initialize
    @teams = Team::ALL + [nil]
  end

  def matches?(request)
    @teams.include? request.params[:team]
  end
end

Rails.application.routes.draw do
  root 'welcome#index'

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  get 'team', to: 'welcome#select_team'
  get 'feedback', to: 'welcome#send_slack_feedback'

  scope "(:team)", constraints: TeamConstraint.new do
    resources :knowledges, only: [:index]
    get 'all', to: 'companies#all'
    get 'voting', to: 'companies#voting'
    resources :companies, only: [:index, :show] do
      resources :votes, only: [:show, :create, :new]
    end
  end

  namespace :api, constraints: { format: :json } do
    namespace :v1 do
      scope "(:team)", constraints: TeamConstraint.new do
        resources :companies, only: [:index, :show] do
          member do
            get 'voting_status'
            post 'allocate'
            post 'reject'
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
end
