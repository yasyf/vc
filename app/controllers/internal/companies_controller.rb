class Internal::CompaniesController < Internal::ApplicationController
  before_action :authenticate_internal_user!

  def all
    companies = apply_filters Company.includes(cards: :list).order(:name)
    @lists = companies.group_by { |c| c.card.list } .sort_by { |l, _| l.pos }
  end

  def index
    @companies = apply_filters Company.pitched.order('pitches.when DESC')
    @heading = 'All Pitches'
  end

  def show
    @company = Company.find(params[:id])
    @vote = @company.pitch.user_votes(current_internal_user).first
  end

  def voting
    @companies = apply_filters Company.pitched.undecided.order('pitches.when DESC')
    @heading = 'Recent Pitches'
    render 'index'
  end

  private

  def apply_filters(companies)
    companies = companies.where(team: team)
    return companies unless params[:filter].present?
    filtered = companies.search(params[:filter])
    if filtered.count > 0
      filtered
    else
      flash_warning "No matches found for '#{params[:filter]}'!"
      companies
    end
  end
end
