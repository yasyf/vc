class External::VcwizController < External::ApplicationController
  before_action :check_founder!, except: [:login, :opt_in, :decide]

  def index
    redirect_to action: :login unless stage == :done
  end

  def login
    @stage = stage
  end

  def admin
    render status: :not_found unless current_external_founder.admin?
  end

  def opt_in
    intro_request.investor.update! opted_in: optin?
    intro_request.decide! accept?
  end

  def decide
    intro_request.decide! accept?
  end

  private

  def optin?
    params[:optin] == 'true'
  end

  def accept?
    params[:accept] == 'true'
  end

  def intro_request
    @intro_request ||= IntroRequest.where(token: params[:token]).first!
  end

  def stage
    if !current_external_founder.present?
      :start
    elsif !company&.complete? || !company&.verified?
      :company
    elsif !target_investors&.present? && !recommendations_shown?
      :suggest
    else
      :done
    end
  end

  def recommendations_shown?
    session[:recommendations_shown]
  end

  def target_investors
    current_external_founder&.target_investors
  end

  def company
    current_external_founder&.primary_company
  end
end
