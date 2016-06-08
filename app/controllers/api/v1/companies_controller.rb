module Api
  module V1
    class CompaniesController < ApplicationController
      before_action :authenticate_user!

      def index
        render json: { companies: Company.pitch.order(pitch_on: :desc) }
      end

      def create
        company = Company.create! company_params
        render json: { company: company }
      end

      private

      def company_params
        params.require(:company).permit(:name, :trello_url)
      end

      def company
        @company ||= Company.find(params[:company_id])
      end
    end
  end
end
