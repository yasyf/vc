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
  match '/500', to: 'errors#internal_server_error', via: :all

  def subdomain_or_prefix(subdomain, prefix, &block)
    namespace(prefix, &block)
    constraints subdomain: subdomain do
      scope(module: prefix, as: "subdomain_#{prefix}", &block)
    end
  end

  root 'welcome#index'

  subdomain_or_prefix(ENV['EXTERNAL_SUBDOMAIN'], :external) do
    root 'welcome#index'

    devise_for :founders, skip: :all
    devise_scope :external_founder do
      get 'auth/callback', to: 'auth#create'
    end

    scope :vcfinder, controller: 'vc_finder', as: :vcfinder do
      root action: 'index'
      get 'login'
      get 'admin'
    end

    namespace :api, defaults: { format: :json } do
      namespace :v1 do
        resources :investors do
          member do
            get 'posts'
          end
          collection do
            get 'search'
            get 'fuzzy_search'
            get 'recommendations'
          end
        end

        resources :target_investors
        resource :founder
      end
    end
  end

  subdomain_or_prefix(ENV['INTERNAL_SUBDOMAIN'], :internal) do
    root 'welcome#index'

    devise_for :users, skip: :all
    devise_scope :internal_user do
      get 'auth/callback', to: 'auth#create'
    end

    get 'team', to: 'welcome#select_team'
    get 'feedback', to: 'welcome#send_slack_feedback'
    get 'stats/show'

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
  end

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: '/emails'
  end

  authenticate :internal_user, lambda { |u| u.admin? } do
    mount Sidekiq::Web, at: '/sidekiq'
  end
end
