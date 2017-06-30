class Internal::CompaniesController < Internal::ApplicationController
  before_action :authenticate_internal_user!

  def all
    companies = apply_filters Company.includes(:list).order(:name)
    @lists = companies.group_by(&:list).sort_by { |l, _| l.pos }
  end

  def index
    @companies = apply_filters Company.pitch.order(pitch_on: :desc)
    @heading = 'All Pitches'
  end

  def show
    @company = Company.find(params[:id])
    @vote = @company.user_votes(current_internal_user).first
  end

  def voting
    @companies = apply_filters Company.pitch.undecided.order(pitch_on: :desc)
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
