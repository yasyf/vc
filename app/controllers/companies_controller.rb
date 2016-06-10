class CompaniesController < ApplicationController
  before_action :authenticate_user!

  def index
    @companies = Company.pitch.order(pitch_on: :desc)
    @heading = 'All Companies'
  end

  def voting
    @companies = Company.pitch.undecided.order(pitch_on: :desc)
    @heading = 'Recent Pitches'
    render 'index'
  end
end
