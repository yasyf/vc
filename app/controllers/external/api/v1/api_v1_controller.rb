class External::Api::V1::ApiV1Controller < External::ApplicationController
  before_action :check_rate_limit!
  before_action :check_api_auth!

  def append_info_to_payload(payload)
    super
    payload[:api_auth] = session[:api_auth]
  end

  def authenticate_api_user!
    authenticate_external_founder!
  end

  def check_api_auth!
    unless session[:api_auth] || Rails.env.test?
      Rails.logger.warn "api.auth: failed check. session: #{session.as_json}"
      head :unauthorized
    end
  end

  def check_rate_limit!
    Prop.throttle!(:api_request_by_user, current_external_founder.id) if external_founder_signed_in?
    Prop.throttle!(:api_request_by_ip, Util.ip_address(request.env))
    Prop.throttle!(:api_request, Util.ip_address(request.env))
  end
end
