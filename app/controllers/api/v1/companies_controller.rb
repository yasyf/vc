module Api
  module V1
    class CompaniesController < ApiV1Controller
      before_action :authenticate_api_user!

      def index
        render json: { companies: Company.all }
      end

      def show
        render json: { company: Company.find(params[:id]) }
      end

      def search
        render json: { results: Company.search(params[:q]) }
      end

      def allocate
        company = Company.find(params[:id])
        user = User.from_slack(params[:user_trello_id])

        return head :bad_request unless company.list == List.application

        company.add_user user
        company.move_to_list! List.allocated

        head :ok
      end
    end
  end
end
