class External::ApplicationController < ::ApplicationController
  layout 'external'
  before_action :populate_gon, :populate_city

  private

  def current_external_investor
    @current_external_investor ||= Investor.find(session[:investor_id]) if session[:investor_id].present?
  end

  def populate_gon
    gon.founder = current_external_founder&.cached_json unless json?
  end

  def populate_city
    session[:city] ||= Util.city(request)
  end

  def check_founder!
    redirect_to external_vcwiz_root_path unless external_founder_signed_in? && authenticate_external_founder!
  end
end