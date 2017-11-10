class External::Api::V1::FoundersController < External::Api::V1::ApiV1Controller
  before_action :authenticate_api_user!

  def show
    render json: founder
  end

  def event
    founder.send("#{event_params[:name]}!", *event_params[:args])
    render json: { error: nil }
  end

  def update
    if founder_company_params[:company].present?
      founder.primary_company.update! founder_company_params[:company].merge(primary: true)
    end
    render json: founder
  end

  private

  def event_params
    params.require(:event).permit(:name, args: [])
  end

  def founder_company_params
    params.require(:founder).permit(company: [:name, :description, :industry, :verified])
  end

  def founder
    @founder ||= current_external_founder
  end
end
