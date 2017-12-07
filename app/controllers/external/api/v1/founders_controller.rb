class External::Api::V1::FoundersController < External::Api::V1::ApiV1Controller
  include External::ApplicationHelper

  before_action :authenticate_api_user!

  def show
    render json: founder
  end

  def event
    founder.send("#{event_params[:name]}!", *event_params[:args])
    render json: { error: nil }
  end

  def update
    if founder_params.present?
      founder.update! founder_params
    end
    if founder_company_params[:primary_company].present?
      founder.primary_company.update! founder_company_params[:primary_company].merge(primary: true)
    end
    render json: founder
  end

  def locations
    render json: arr_to_options(Founder.locations(params[:q]))
  end

  def disable_scanner
    founder.update! history_id: nil
    render json: founder
  end

  private

  def event_params
    params.require(:event).permit(:name, args: [])
  end

  def founder_company_params
    params.require(:founder).permit(primary_company: [:name, :domain, :description])
  end

  def founder_params
    params.require(:founder).permit(:city, :twitter, :linkedin, :homepage)
  end

  def founder
    @founder ||= current_external_founder
  end
end
