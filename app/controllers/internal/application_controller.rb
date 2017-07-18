class Internal::ApplicationController < ::ApplicationController
  layout 'internal'
  before_action :populate_gon
  before_action :check_team!

  private

  def populate_gon
    gon.user = current_internal_user
  end

  def check_team!
    if current_internal_user.present? && !view_context.current_page?(internal_team_path)
      if current_internal_user.team.blank?
        session[:original_path] = request.path
        redirect_to internal_team_path
      else
        session[:original_path] = request.path.gsub(current_internal_user.team.name, '<TEAM>')
      end
    end
  end

  def default_url_options(options = {})
    options.reverse_merge(team: team&.name)
  end

  def team
    @team ||= params[:team].present? ? Team.send(params[:team]) : current_internal_user&.team
  end
end
