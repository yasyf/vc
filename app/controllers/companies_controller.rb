class CompaniesController < ApplicationController
  before_action :authenticate_user!

  def index
    @companies = Company.pitch.order(pitch_on: :desc)
  end
end
