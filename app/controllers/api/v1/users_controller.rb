module Api
  module V1
    class UsersController < ApiV1Controller
      before_action :authenticate_api_user!

      def show
        render json: current_user
      end

      def token
        render json: { token: current_user.ensure_token }
      end

      def toggle_active
        current_user.toggle_active!
        render json: { active: current_user.active? }
      end

      def set_team
        current_user.update!(team: Team.send(params[:team]))
        team_name = current_user.team.name
        render json: { team: team_name, redirect: session[:original_path].gsub('<TEAM>', team_name) }
      end

      private

      def vote_params
        params.require(:vote).permit(:final, :overall, :reason, *Vote::METRICS)
      end

      def company
        @company ||= Company.find(params[:company_id])
      end
    end
  end
end
