class External::Api::V1::InvestorsController < External::Api::V1::ApiV1Controller
  include External::Concerns::Censorable

  before_action :authenticate_api_user!

  filter %w(comments competitor.comments)

  def index
    render_censored Investor.order(updated_at: :asc).limit(25).offset(page * 25)
  end

  def search
    existing = current_external_founder.target_investors.select('investor_id')
    results = Investor
                .includes(:competitor)
                .references(:competitors)
                .fuzzy_search({ first_name: params[:q], last_name: params[:q], competitors: { name: params[:q] } }, false)
                .where.not(id: existing)
                .order('featured')
    render_censored results
  end


  def update
    investor = Investor.find(params[:id])

    if investor_params.present?
      investor.update! investor_params
    end

    if investor_note_params.present?
      note = investor.notes.first_or_initialize(founder: current_external_founder)
      note.body = investor_note_params[:note]
      note.save!
    end

    if competitor_params[:competitor].present?
      investor.competitor.update! competitor_params[:competitor]
    end

    if competitor_note_params[:competitor].present?
      note = investor.competitor.notes.first_or_initialize(founder: current_external_founder)
      note.body = competitor_note_params[:competitor][:note]
      note.save!
    end

    render_censored investor
  end

  private

  def page
    (params[:page] || 0).to_i
  end

  def investor_params
    params.require(:investor).permit(:industry, :funding_size)
  end

  def investor_note_params
    params.require(:investor).permit(:note)
  end

  def competitor_params
    params.require(:investor).permit(competitor: [:industry, :funding_size])
  end

  def competitor_note_params
    params.require(:investor).permit(competitor: :note)
  end
end
