module Api
  module V1
    class VotesController < ApplicationController
      def index
        render json: { votes: company.votes }
      end

      def create
        vote = company.votes.create! vote_params.merge(user: current_user)
        render json: { vote: vote }
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
