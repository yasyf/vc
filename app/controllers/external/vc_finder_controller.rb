class External::VcFinderController < External::ApplicationController
  before_action :check_founder!, except: :login

  def index
    redirect_to action: :login unless stage == :done
  end

  def login
    @stage = stage
  end

  def admin
    render status: :not_found unless current_external_founder.admin?
  end

  private

  def stage
    if !current_external_founder.present?
      :start
    elsif !company&.complete? || !company&.verified?
      :company
    elsif !investor_profile&.present?
      :profile
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

  def investor_profile
    current_external_founder&.investor_profile
  end

  def company
    current_external_founder&.companies&.last
  end
end
