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
      mount PgHero::Engine, at: '/pghero'
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
        get 'auth/create', to: 'auth#create'
        get 'auth/enhance', to: 'auth#enhance'
        get 'auth/failure', to: 'auth#failure'
        authenticate :external_founder, lambda { |u| u.admin? } do
          get 'auth/impersonate/:id', to: 'auth#impersonate', as: :impersonate
        end
      end

      scope controller: 'vcwiz/vcwiz', as: :vcwiz do
        root action: 'discover'
        get 'firm/:id(/:slug)', action: :firm, as: :firm
        get 'investor/:id(/:slug)', action: :investor, as: :investor
        get 'company/:id(/:slug)', action: :company, as: :company
        get 'privacy'
        get 'terms'
        get 'discover'
        get 'filter'
        get 'search'
        get 'list/:list(/:key/:value)', action: :list, as: :list
        get 'outreach'
        get 'gmail_auth'
        get 'login'
        post 'login'
        post 'signup'

        scope :intro, as: :intro, controller: 'vcwiz/intro' do
          get 'opt_in'
          get 'decide'
          get 'pixel/:token.png', action: :pixel, as: :pixel
        end

        scope :investors, as: :investors, controller: 'vcwiz/investors' do
          root action: 'index'
          get 'token/:token', action: :token, as: :token
          get 'impersonate/:investor_id', action: :impersonate, as: :impersonate
          get 'signup'
          get 'settings'
          get 'contacts'
          post 'update_contacts'
        end

        scope :founders, as: :founders, controller: 'vcwiz/founders' do
          get 'unsubscribe/(:token)', action: :unsubscribe, as: :unsubscribe
        end
      end

      namespace :api, defaults: { format: :json } do
        namespace :v1 do
          resources :intros, only: [:index, :show, :create] do
            member do
              post 'preview'
              post 'confirm'
            end
          end

          resources :investors, except: [:index] do
            member do
              get 'interactions'
              get 'intro_paths'
              post 'verify'
            end

            collection do
              get 'filter'
              get 'search'
              get 'fuzzy_search'
              get 'entities'
              get 'recommendations'
              get 'locations'
              post 'add'
            end
          end

          resources :companies, only: [:show] do
            collection do
              get 'search'
              get 'query'
            end
          end

          resources :competitors, only: [:show, :update] do
            member do
              get 'intro_paths'
            end

            collection do
              get 'filter'
              get 'filter_count'
              get 'locations'
              get 'intro_path_counts'
              get 'lists'
              get 'list/:list(/:key/:value)', action: :list, as: :list
            end
          end

          resource :message, only: [:create] do
            post 'open'
            post 'click'
            post 'bounce'
            post 'unsubscribe'
            post 'demo'
          end

          resource :pubsub, only: [] do
            post 'generation'
          end

          resources :target_investors do
            collection do
              post 'import'
              post 'bulk_import'
              get 'poll/:id', action: :bulk_poll, as: :bulk_poll
            end
          end

          resource :founder, only: [:show, :update] do
            post 'disable_scanner'
            post 'event'
            get 'locations'
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
        get 'auth/create', to: 'auth#create'
        get 'auth/failure', to: 'auth#failure'
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
          member do
            post 'create_snapshot'
          end
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
