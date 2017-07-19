class External::VcFinderController < External::ApplicationController
  before_action :check_founder!

  def index
  end

  def admin
    render status: :not_found unless current_external_founder.admin?
  end
end
