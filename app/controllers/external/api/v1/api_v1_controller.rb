class External::Api::V1::ApiV1Controller < External::ApplicationController
  before_action :check_rate_limit!

  def authenticate_api_user!
    authenticate_external_founder!
  end

  def check_rate_limit!
    Prop.throttle!(:api_request_by_user, current_external_founder.id) if external_founder_signed_in?
    Prop.throttle!(:api_request_by_ip, Util.ip_address(request.env))
    Prop.throttle!(:api_request, Util.ip_address(request.env))
  end
end
