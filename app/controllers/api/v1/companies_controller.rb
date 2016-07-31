module Api
  module V1
    class CompaniesController < ApplicationController
      before_action :authenticate_user!

      def index
        render json: { features: Company.decided.map(&:features) }
      end
    end
  end
end
