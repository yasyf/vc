class ApplicationController < ActionController::Base
  include ApplicationHelper

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :set_raven_context
  before_action :set_csrf_token

  private

  def json?
    request.format == 'application/json'
  end

  def set_csrf_token
    gon.csrf_token = form_authenticity_token
  end

  def set_raven_context
    user = current_internal_user || current_external_founder
    context = {
      id: user.try(:id),
      name: user.try(:name),
      email: user.try(:email),
    }
    gon.user_context = context

    Raven.user_context(context)
    Raven.extra_context(params: params.to_unsafe_h, url: request.url, session: session.to_hash)
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

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end
end
