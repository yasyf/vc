class External::ApplicationController < ::ApplicationController
  layout 'external'
  before_action :populate_gon

  private

  def populate_gon
    gon.founder = current_external_founder&.cached_json
  end

  def check_founder!
    redirect_to external_vcwiz_root_path unless external_founder_signed_in? && authenticate_external_founder!
  end
end
