class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :check_team!
  before_action :set_raven_context

  private

  def set_raven_context
    Raven.user_context(id: current_user.try(:id))
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end

  def check_team!
    if current_user.present? && !view_context.current_page?(team_path)
      if current_user.team.blank?
        session[:original_path] = request.path
        redirect_to team_path
      else
        session[:original_path] = request.path.gsub(current_user.team.name, '<TEAM>')
      end
    end
  end

  def default_url_options(options = {})
    options.reverse_merge(team: team&.name)
  end

  def team
    @team ||= params[:team].present? ? Team.send(params[:team]) : current_user&.team
  end

  def flash_warning(warning)
    flash.now[:warning] ||= []
    flash.now[:warning] << warning
  end

  def flash_errors(record)
    flash[:alert] ||= []
    record.errors.messages.each do |attribute, messages|
      messages.each { |message| flash[:alert] << "#{attribute.to_s.titleize} #{message}" }
    end
  end
end
