class VotesController < ApplicationController
  before_action :authenticate_user!

  def show
  end

  def new
    @vote = company.user_votes(current_user).first_or_initialize
  end

  def create
    vote = company.votes.create vote_params.merge(user: current_user)
    if vote.valid?
      flash[:success] = "Vote submitted!"
    else
      flash_errors vote
    end
    redirect_to action: :new
  end

  private

  def vote_params
    params.require(:vote).permit(:final, :overall, :reason, *Vote::METRICS)
  end

  def company
    @company ||= Company.find(params[:company_id])
  end
end
