class External::ApplicationController < ::ApplicationController
  layout 'external'
  before_action :populate_gon, :populate_city

  private

  def populate_gon
    gon.founder = current_external_founder&.cached_json
  end

  def populate_city
    session[:city] ||= (city = Util.city(request)).present? ? city : (current_external_founder&.city || 'San Francisco')
  end

  def check_founder!
    redirect_to external_vcwiz_root_path unless external_founder_signed_in? && authenticate_external_founder!
  end
end