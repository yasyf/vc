class External::AuthController < Devise::OmniauthCallbacksController
  ILLEGAL_DOMAINS = %w(gmail.com)

  def create
    auth = request.env["omniauth.auth"]
    if auth.info.email.split('@').last.in?(ILLEGAL_DOMAINS)
      set_flash_message :alert, :failure, kind: 'Google', reason: 'a personal account cannot be used'
      return redirect_to external_root_path
    end

    @founder = Founder.from_omniauth(auth)

    if @founder.present?
      set_flash_message :notice, :success, kind: 'Google'
      sign_in_and_redirect @founder, event: :authentication
    else
      set_flash_message :alert, :failure, kind: 'Google', reason: 'an error occurred'
      redirect_to external_root_path
    end
  end

  def failure
    redirect_to external_root_path
  end
end
