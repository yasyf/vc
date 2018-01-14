class Internal::CompaniesController < Internal::ApplicationController
  include External::Concerns::Pageable

  INCLUDES = [:team, users: :team, pitches: [:votes, :team], cards: :list]
  LIMIT = 25

  before_action :authenticate_internal_user!

  def all
    flash_if_no_filter unless params[:filter].present?
    companies = apply_filters Company.order(:name, :id).limit(LIMIT)
    lists = companies.joins(cards: :list).pluck('DISTINCT ON(companies.name, companies.id) companies.id, lists.id, lists.pos, lists.name')
    company_lists = lists.map { |l| l.first(2) }.to_h
    list_positions = lists.map { |l| l.drop(1).first(2) }.to_h
    list_names = lists.map { |l| [l[1], l.last] }.to_h
    @lists = companies
      .includes(*INCLUDES)
      .group_by { |c| company_lists[c.id] }
      .sort_by { |lid, cs| list_positions[lid] }
      .map { |lid, cs| [list_names[lid], cs] }
  end

  def index
    flash_if_no_filter unless params[:filter].present?
    @companies = apply_filters Company.includes(*INCLUDES).pitched.order('pitches.when DESC').limit(LIMIT)
    @heading = 'All Pitches'
  end

  def show
    @company = Company.includes(*INCLUDES).find(params[:id])
    @vote = @company.pitch&.user_votes(current_internal_user)&.first
  end

  def voting
    @companies = apply_filters Company.includes(*INCLUDES).pitched.undecided.order('pitches.when DESC')
    @heading = 'Recent Pitches'
    render 'index'
  end

  private

  def flash_if_no_filter
    flash_warning 'Some results not shown! Please use the search bar'
  end

  def apply_filters(companies)
    companies = companies
                  .joins(:cards, :team)
                  .where('cards.archived = ?', false)
                  .where(team: team)

    return companies unless params[:filter].present?

    filtered = companies.search(params[:filter])
    if filtered.count('DISTINCT id') > 0
      filtered
    else
      flash_warning "No matches found for '#{params[:filter]}'!"
      companies
    end
  end
end
