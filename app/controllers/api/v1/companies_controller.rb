module Api
  module V1
    class CompaniesController < ApiV1Controller
      before_action :authenticate_api_user!

      def index
        render json: { companies: params[:team].present? ? Company.where(team: team) : Company.all }
      end

      def show
        render json: { company: Company.find(params[:id]) }
      end

      def search
        render json: { results: Company.search(params[:q]) }
      end

      def voting_status
        company = Company.find(params[:id])
        unless company.votes.present?
          render json: { status: :not_started }
          return
        end
        users = company.missing_vote_users
        if users.present?
          render json: { status: :missing_users, users: users }
        else
          render json: { status: :complete, funded: company.funded? }
        end
      end

      def invalidate_crunchbase
        Company.find(params[:id]).invalidate_crunchbase_id!

        head :ok
      end

      def allocate
        company = Company.find(params[:id])
        user = User.from_slack(params[:user_slack_id])

        return head :bad_request unless company.team == user.team
        return head :bad_request unless company.list.pos < company.team.lists.allocated.pos

        company.add_user user
        company.move_to_list! company.team.lists.allocated

        head :ok
      end

      def reject
        company = Company.find(params[:id])
        return head :bad_request if company.list.in?([
          company.team.lists.rejected,
          company.team.lists.passed,
          company.team.lists.scheduled,
          company.team.lists.funded,
        ])
        company.move_to_rejected_list!

        head :ok
      end
    end
  end
end
