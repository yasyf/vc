class External::Api::V1::FoundersController < External::Api::V1::ApiV1Controller
  before_action :authenticate_api_user!

  def show
    founder.create_company! if founder.companies.blank?
    render json: founder
  end

  def click
    founder.investor_clicked! click_params[:id]
  end

  def update
    if founder_company_params[:company].present?
      founder.primary_company.update! founder_company_params[:company].merge(primary: true)
    end

    render json: founder
  end

  private

  def click_params
    params.require(:investor).permit(:id)
  end

  def founder_company_params
    params.require(:founder).permit(company: [:name, :description, :industry, :verified])
  end

  def founder
    @founder ||= current_external_founder
  end
end
