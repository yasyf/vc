class Internal::VotesController < Internal::ApplicationController
  before_action :authenticate_internal_user!

  def show
    @vote = fetch_vote
  end

  def new
    @vote = company.pitch.user_votes(current_internal_user).first_or_initialize
  end

  def create
    vote = company.pitch.votes.create vote_params.merge(user: current_internal_user)
    if vote.valid?
      flash[:success] = "Vote submitted!"
      redirect_to internal_company_path(company)
    else
      flash_errors vote
      redirect_to action: :new
    end
  end

  private

  def vote_params
    params.require(:vote).permit(:final, :overall, :reason, *Vote::METRICS)
  end

  def fetch_vote
    vote = Vote.find(params[:id])
    raise ActiveRecord::RecordNotFound unless vote.company == company
    vote
  end

  def company
    @company ||= Company.find(params[:company_id])
  end
end
