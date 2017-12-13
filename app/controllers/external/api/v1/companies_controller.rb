class External::Api::V1::CompaniesController < External::Api::V1::ApiV1Controller
  include External::ApplicationHelper

  LIMIT = 5

  def show
    render json: Company.find(params[:id])
  end

  def query
    render json: (Company.where(domain: params[:domain]).first if params[:domain].present?)
  end

  def search
    render json: [] and return unless params[:q].present?
    companies = Company.where(team: nil).or(Company.where('capital_raised > ?', 0))
    companies = companies.order('domain IS NOT NULL DESC')
    companies = companies.fuzzy_search(name: params[:q])
    companies = companies.order(capital_raised: :desc, domain: :asc).limit(LIMIT).map(&:as_json_search)
    render json: records_to_options(companies)
  end
end
