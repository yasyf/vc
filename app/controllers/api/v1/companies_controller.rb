module Api
  module V1
    class CompaniesController < ApiV1Controller
      before_action :authenticate_api_user!

      def index
        render json: { features: Company.decided.map(&:features) }
      end

      def show
        render json: { company: Company.find(params[:id]) }
      end

      def search
        render json: { results: Company.search(params[:q]) }
      end
    end
  end
end
