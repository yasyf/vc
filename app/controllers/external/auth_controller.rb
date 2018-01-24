class External::AuthController < Devise::OmniauthCallbacksController
  include External::ApplicationHelper

  def destroy
    sign_out current_external_founder
    redirect_to external_vcwiz_root_path
  end

  def create
    auth = request.env['omniauth.auth']
    founder = Founder.from_omniauth(auth)

    if founder.present?
      signin_founder founder
      redirect_after_signup founder
    else
      redirect_after_failure
    end
  end

  def enhance
    auth = request.env['omniauth.auth']
    founder = Founder.from_omniauth(auth)

    if external_founder_signed_in?
      process_gmail_auth founder
      redirect_to after_sign_in_path_for(current_external_founder)
    else
      if founder.present?
        signin_founder founder
        process_gmail_auth founder
        redirect_after_signup founder
      else
        redirect_after_failure
      end
    end
  end

  def failure
    if params[:message] == 'access_denied' && params[:strategy] == 'gmail' && !external_founder_signed_in?
      redirect_to omniauth_path('google_external', hd: cookies[:login_domain])
    else
      redirect_to external_founder_signed_in? ? after_sign_in_path_for(current_external_founder) : external_vcwiz_root_path
    end
  end

  private

  def process_gmail_auth(founder)
    if founder == current_external_founder
      founder.update! history_id: 0
      FounderGmailSyncJob.new(founder.id).enqueue(queue: :long_now)
      flash_success 'VCWiz Link has been enabled! As you send emails to investors, this tracker will update.'
    else
      flash_failure 'That user is not logged in'
    end
  end

  def redirect_after_failure
    flash_failure 'A login error occured'
    redirect_to external_vcwiz_root_path
  end

  def redirect_after_signup(founder)
    if founder.primary_company.blank? && session[:signup_data].blank? && !founder.admin?
      flash_failure "You don't have an account yet! Please sign up below"
      sign_out current_external_founder if current_external_founder.present?
      session[:open_signup] = true
      redirect_to external_vcwiz_root_path
    else
      cookies.permanent[:login_domain] = founder.domain == 'gmail.com' ? nil : founder.domain
      redirect_to after_sign_in_path_for(current_external_founder)
    end
  end

  def signin_founder(founder)
    if session[:signup_data].present?
      founder.create_company! session[:signup_data].with_indifferent_access
      session.delete(:signup_data)
      founder.ensure_target_investors!
      founder.signed_up!
      SummaryMailer.welcome_founder_email(founder).deliver_later
      session[:new_login] = true
      cookies.delete(:filters)
    end
    founder.logged_in!
    sign_in founder
  end
end
