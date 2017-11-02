require 'sidekiq/web'
require 'zhong/web'

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

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: '/emails'
  end

  def admin_dashboards(scope)
    authenticate scope, lambda { |u| u.admin? } do
      mount Sidekiq::Web, at: '/sidekiq'
      mount Zhong::Web, at: '/zhong'
    end
  end

  def code_scope(scope, &block)
    scope module: scope, as: scope, &block
  end

  code_scope :external do
    devise_for :founders, skip: :all

    if Rails.application.vcwiz?
      devise_scope :external_founder do
        get 'logout', to: 'auth#destroy'
        get 'auth/callback', to: 'auth#create'
      end

      scope :vcfinder, controller: 'vc_finder', as: :vcfinder do
        root action: 'index'
        get 'login'
        get 'admin'

        scope :intro do
          get 'opt_in'
          get 'decide'
        end
      end

      scope controller: 'vcwiz', as: :vcwiz do
        root action: 'index'
        get 'discover'
        get 'filter'
        get 'list/:list', action: :list, as: :list
        get 'outreach'
        get 'login'
        post 'signup'

        scope :intro do
          get 'opt_in'
          get 'decide'
        end
      end

      namespace :api, defaults: { format: :json } do
        namespace :v1 do
          resources :investors do
            member do
              get 'review'
            end

            collection do
              get 'filter'
              get 'search'
              get 'fuzzy_search'
              get 'recommendations'
              get 'locations'
            end
          end

          resources :companies, only: [:show] do
            collection do
              get 'search'
              get 'query'
            end
          end

          resources :competitors, only: [:show] do
            collection do
              get 'filter'
              get 'filter_count'
              get 'locations'
              get 'lists'
              get 'list/:list', action: :list, as: :list
            end
          end

          resource :message, only: [:create] do
            post 'open'
            post 'click'
          end

          resource :pubsub, only: [] do
            post 'generation'
          end

          resource :intro, only: [:create]

          resources :target_investors do
            collection do
              post 'import'
              post 'bulk_import'
            end
          end

          resource :founder do
            post 'click'
          end
        end
      end

      admin_dashboards :external_founder
    end
  end

  code_scope :internal do
    devise_for :users, skip: :all

    if Rails.application.drfvote?
      root 'welcome#index'

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

      admin_dashboards :internal_user
    end
  end
end
