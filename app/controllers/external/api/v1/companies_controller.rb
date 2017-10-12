class External::Api::V1::CompaniesController < External::Api::V1::ApiV1Controller
  include External::ApplicationHelper

  LIMIT = 5

  before_action :authenticate_api_user!

  def show
    render json: Company.find(params[:id])
  end

  def search
    render json: [] and return unless params[:q].present?
    companies = Company.where(team: nil).or(Company.where('capital_raised > ?', 0))
    companies = companies.fuzzy_search(name: params[:q])
    companies = companies.order(capital_raised: :desc).limit(LIMIT).map(&:as_json_search)
    render json: records_to_options(companies)
  end
end
