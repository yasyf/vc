class External::AuthController < Devise::OmniauthCallbacksController
  def destroy
    sign_out current_external_founder
    redirect_to external_root_path
  end

  def create
    auth = request.env['omniauth.auth']
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
