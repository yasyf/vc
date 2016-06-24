class CompaniesController < ApplicationController
  before_action :authenticate_user!

  def all
    @lists = Company.includes(:list).order(:name).group_by(&:list).sort_by { |l, _| l.pos }
  end

  def index
    @companies = Company.pitch.order(pitch_on: :desc)
    @heading = 'All Pitches'
  end

  def show
    @company = Company.find(params[:id])
    @vote = @company.vote_for_user(current_user)
  end

  def voting
    @companies = Company.pitch.undecided.order(pitch_on: :desc)
    @heading = 'Recent Pitches'
    render 'index'
  end
end
