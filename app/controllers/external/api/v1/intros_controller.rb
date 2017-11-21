class External::Api::V1::IntrosController < External::Api::V1::ApiV1Controller
  before_action :authenticate_api_user!

  def index
    intro = IntroRequest.where(target_investor_id: params[:target_investor_id]).first_or_initialize
    render json: intro.as_json(methods: [])
  end

  def show
    render json: intro
  end

  def create
    target_investor = TargetInvestor.find(intro_request_params[:target_investor_id])
    target_investor.update! email: intro_request_params[:email] if intro_request_params[:email].present?
    intro = IntroRequest.from_target_investor target_investor
    intro.update! intro_request_params.slice(:context, :pitch_deck)
    render json: intro
  end

  def preview
    intro.update! preview_html: nil
    intro.start_preview_job!
    render json: intro
  end

  def confirm
    intro.send!
    render json: intro
  end

  private

  def intro
    @intro ||= IntroRequest.find(params[:id])
  end

  def intro_request_params
    params.require(:intro_request).permit(:target_investor_id, :email, :context, :pitch_deck)
  end
end
