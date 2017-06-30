class Internal::KnowledgesController < Internal::ApplicationController
  before_action :authenticate_internal_user!

  def index
    @knowledges = Knowledge.where(team: team).order(created_at: :desc)
  end
end
