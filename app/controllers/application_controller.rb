class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :check_team!

  private

  def append_info_to_payload(payload)
    super
    payload[:host] = request.host
    payload[:source_ip] = request.remote_ip
    payload[:user_id] = current_user.try(:id)
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
