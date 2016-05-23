module Api
  module V1
    class CompaniesController < ApplicationController
      def index
        render json: { companies: Companies.all }
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
