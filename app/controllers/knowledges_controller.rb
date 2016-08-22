class KnowledgesController < ApplicationController
  before_action :authenticate_user!

  def index
    @knowledges = Knowledge.where(team: team).order(created_at: :desc)
  end
end
