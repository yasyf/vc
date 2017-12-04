class External::AuthController < Devise::OmniauthCallbacksController
  def destroy
    sign_out current_external_founder
    redirect_to external_vcwiz_root_path
  end

  def create
    auth = request.env['omniauth.auth']
    founder = Founder.from_omniauth(auth)

    if founder.present?
      if session[:signup_data].present?
        founder.create_company! session[:signup_data].with_indifferent_access
        session.delete(:signup_data)
        founder.ensure_target_investors!
      end
      cookies.permanent[:login_domain] = founder.domain
      sign_in_and_redirect founder, event: :authentication
    else
      set_flash_message :alert, :failure, kind: 'Google', reason: 'an error occurred'
      redirect_to external_vcwiz_root_path
    end
  end

  def enhance
    auth = request.env['omniauth.auth']
    founder = Founder.from_omniauth(auth)
    if founder != current_external_founder
      set_flash_message :alert, :failure, kind: 'Google', reason: 'that user is not logged in'
    end
    redirect_to after_sign_in_path_for(current_external_founder)
  end

  def failure
    redirect_to external_vcwiz_root_path
  end
end
