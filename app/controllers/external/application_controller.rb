class External::ApplicationController < ::ApplicationController
  layout 'external'

  private

  def check_founder!
    redirect_to omniauth_path('google_external') unless external_founder_signed_in? && authenticate_external_founder!
  end
end
