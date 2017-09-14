class Internal::CompaniesController < Internal::ApplicationController
  PER_PAGE = 50

  before_action :authenticate_internal_user!

  def all
    companies = apply_filters Company.order(:name)
    @lists = companies.group_by { |c| c.card.list } .sort_by { |l, _| l.pos }
  end

  def index
    @companies = apply_filters Company.pitched.order('pitches.when DESC')
    @heading = 'All Pitches'
  end

  def show
    @company = Company.find(params[:id])
    @vote = @company.pitch&.user_votes(current_internal_user)&.first
  end

  def voting
    @companies = apply_filters Company.pitched.undecided.order('pitches.when DESC')
    @heading = 'Recent Pitches'
    render 'index'
  end

  private

  def page
    (params[:page] || 0).to_i
  end

  def apply_filters(companies)
    companies = companies
                  .includes(:users, :team, pitches: :votes, cards: :list)
                  .joins(:cards)
                  .where('cards.archived = ?', false)
                  .where(team: team)
    return companies unless params[:filter].present?

    filtered = companies.search(params[:filter])
    results = if filtered.count('*') > 0
      filtered
    else
      flash_warning "No matches found for '#{params[:filter]}'!"
      companies
    end

    results.limit(PER_PAGE).offset(page * PER_PAGE)
  end
end
