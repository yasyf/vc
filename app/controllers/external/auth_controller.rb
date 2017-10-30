class External::AuthController < Devise::OmniauthCallbacksController
  def destroy
    sign_out current_external_founder
    redirect_to external_vcwiz_root_path
  end

  def create
    auth = request.env['omniauth.auth']
    @founder = Founder.from_omniauth(auth)

    if @founder.present?
      @founder.create_company! session[:signup_data].with_indifferent_access
      sign_in_and_redirect @founder, event: :authentication
    else
      set_flash_message :alert, :failure, kind: 'Google', reason: 'an error occurred'
      redirect_to external_vcwiz_root_path
    end
  end

  def failure
    redirect_to external_vcwiz_root_path
  end
end
