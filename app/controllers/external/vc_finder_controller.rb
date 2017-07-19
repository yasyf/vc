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
    if investor_profile&.complete?
      :done
    elsif company&.complete? && company&.verified?
      :profile
    elsif current_external_founder.present?
      :company
    else
      :start
    end
  end

  def investor_profile
    current_external_founder&.investor_profile
  end

  def company
    current_external_founder&.companies&.last
  end
end
