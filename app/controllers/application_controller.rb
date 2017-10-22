class ApplicationController < ActionController::Base
  include ApplicationHelper

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :set_raven_context
  before_action :set_csrf_token

  private

  def set_csrf_token
    gon.csrf_token = form_authenticity_token
  end

  def set_raven_context
    context = {
      id: current_internal_user.try(:id) || current_external_founder.try(:id),
      name: current_internal_user.try(:name) || current_external_founder.try(:name),
      email: current_internal_user.try(:email) || current_external_founder.try(:email),
    }
    gon.user_context = context

    Raven.user_context(context)
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
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

  def internal_path(prefix)
    internal? ? eval("subdomain_internal_#{prefix}_path") : eval("internal_#{prefix}_path")
  end

  def external_path(prefix)
    external? ? eval("subdomain_external_#{prefix}_path") : eval("external_#{prefix}_path")
  end

  def internal?
    request.subdomain == ENV['INTERNAL_SUBDOMAIN']
  end

  def external?
    request.subdomain == ENV['EXTERNAL_SUBDOMAIN']
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end
end
