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
    redirect_to external_founder_signed_in? ? after_sign_in_path_for(current_external_founder) : external_vcwiz_root_path
  end

  private

  def process_gmail_auth(founder)
    if founder == current_external_founder
      founder.update! history_id: 0
      FounderGmailSyncJob.new(founder.id).enqueue(queue: :long_now)
      flash_success 'The VCWiz Inbox Scanner has been enabled! As you send emails to investors, this tracker will update.'
    else
      set_flash_message :alert, :failure, kind: 'Google', reason: 'that user is not logged in'
    end
  end

  def redirect_after_failure
    set_flash_message :alert, :failure, kind: 'Google', reason: 'an error occurred'
    redirect_to external_vcwiz_root_path
  end

  def redirect_after_signup(founder)
    if founder.primary_company.blank? && session[:signup_data].blank? && !founder.admin?
      set_flash_message :alert, :failure, kind: 'Google', reason: "you don't have an account yet! Please sign up below"
      sign_out current_external_founder if current_external_founder.present?
      session[:open_signup] = true
      redirect_to external_vcwiz_root_path
    else
      cookies.permanent[:login_domain] = founder.domain unless founder.domain == 'gmail.com'
      redirect_to after_sign_in_path_for(current_external_founder)
    end
  end

  def signin_founder(founder)
    if session[:signup_data].present?
      founder.create_company! session[:signup_data].with_indifferent_access
      session.delete(:signup_data)
      founder.ensure_target_investors!
      SummaryMailer.welcome_founder_email(founder).deliver_later
      session[:new_login] = true
    end
    sign_in founder
  end
end
