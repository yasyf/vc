class External::Api::V1::FoundersController < External::Api::V1::ApiV1Controller
  before_action :authenticate_api_user!

  def show
    founder.create_company! if founder.companies.blank?
    founder.create_investor_profile! if founder.investor_profile.blank?
    render json: founder
  end

  def update
    if founder_profile_params[:investor_profile].present?
      founder.investor_profile.update! founder_profile_params[:investor_profile]
    end

    if founder_company_params[:company].present?
      founder.company.update! founder_company_params[:company]
    end

    render json: founder
  end

  private

  def founder_company_params
    params.require(:founder).permit(company: [:name, :description, :industry, :verified])
  end

  def founder_profile_params
    params.require(:founder).permit(investor_profile: [:city, :funding_size, :industry])
  end

  def founder
    @founder ||= current_external_founder
  end
end
