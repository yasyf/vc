class External::Api::V1::InvestorsController < External::Api::V1::ApiV1Controller
  include External::Concerns::Censorable

  before_action :authenticate_api_user!

  filter :comments

  def index
    render_censored Investor.order(updated_at: :asc).limit(25).offset(page * 25)
  end

  def search
    existing = current_external_founder.target_investors.select('investor_id')
    render_censored Investor.includes(:competitor).fuzzy_search(params[:q]).where.not(id: existing)
  end

  private

  def page
    (params[:page] || 0).to_i
  end
end
