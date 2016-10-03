class StatsController < ApplicationController
  before_action :authenticate_user!

  def index
    team
  end
end
