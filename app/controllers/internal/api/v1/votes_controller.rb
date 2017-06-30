class Internal::Api::V1::VotesController < Internal::Api::V1::ApiV1Controller
  before_action :authenticate_api_user!

  def index
    votes = params[:team].present? ? Vote.joins(:company).where('companies.team_id = ?', team.id) : Vote.all
    respond_to do |format|
      format.json { render json: { votes: votes } }
      format.csv { render text: votes.includes(:company, :user).to_csv }
    end
  end

  def show
    render json: { vote: Vote.find(params[:id]) }
  end
end
