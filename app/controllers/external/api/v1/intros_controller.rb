class External::Api::V1::IntrosController < External::Api::V1::ApiV1Controller
  before_action :authenticate_api_user!

  def index
    target_investor = TargetInvestor.find(params[:target_investor_id])
    intro = IntroRequest.from_target_investor(target_investor)
    render json: intro.as_json(methods: [])
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.first.last }
  end

  def show
    render json: intro
  end

  def create
    target_investor = TargetInvestor.find(intro_request_params[:target_investor_id])
    intro = IntroRequest.from_target_investor(target_investor)

    target_investor.update! email: intro_request_params[:email] if intro_request_params[:email].present?
    intro.update! intro_request_params.slice(:context, :pitch_deck)
    render json: intro
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.first }
  end

  def preview
    intro.update! preview_html: nil
    intro.start_preview_job!
    render json: intro
  end

  def confirm
    intro.update! preview_html: nil
    intro.send!
    intro.target_investor.update! stage: TargetInvestor::RAW_STAGES.keys.index(:intro)
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
