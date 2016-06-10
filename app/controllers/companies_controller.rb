class CompaniesController < ApplicationController
  before_action :authenticate_user!

  def all
    @companies = Company.order(:name)
  end

  def index
    @companies = Company.pitch.order(pitch_on: :desc)
    @heading = 'All Pitches'
  end

  def voting
    @companies = Company.pitch.undecided.order(pitch_on: :desc)
    @heading = 'Recent Pitches'
    render 'index'
  end
end
