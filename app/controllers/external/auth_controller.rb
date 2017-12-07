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
      if founder.primary_company.blank? && session[:signup_data].blank? && !founder.admin?
        set_flash_message :alert, :failure, kind: 'Google', reason: "you don't have an account yet! Please sign up below"
        redirect_to external_vcwiz_root_path
      else
        cookies.permanent[:login_domain] = founder.domain
        sign_in_and_redirect founder, event: :authentication
      end
    else
      set_flash_message :alert, :failure, kind: 'Google', reason: 'an error occurred'
      redirect_to external_vcwiz_root_path
    end
  end

  def enhance
    auth = request.env['omniauth.auth']
    founder = Founder.from_omniauth(auth)
    if founder == current_external_founder
      founder.update! history_id: 0
      FounderGmailSyncJob.new(founder.id).enqueue(queue: :high)
      flash[:success] = 'The VCWiz Inbox Scanner has been enabled! As you send emails to investors, this tracker will update.'
    else
      set_flash_message :alert, :failure, kind: 'Google', reason: 'that user is not logged in'
    end
    redirect_to after_sign_in_path_for(current_external_founder)
  end

  def failure
    redirect_to external_founder_signed_in? ? after_sign_in_path_for(current_external_founder) : external_vcwiz_root_path
  end
end
