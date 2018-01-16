class External::FrontendController < External::ApplicationController
  include External::ApplicationHelper
  include External::Concerns::Reactable

  layout 'vcwiz'

  before_action :set_api_auth!

  private

  def set_api_auth!
    session[:api_auth] ||= true
  end
end