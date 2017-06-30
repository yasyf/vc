class Internal::StatsController < Internal::ApplicationController
  before_action :authenticate_internal_user!

  def index
    team
  end
end
