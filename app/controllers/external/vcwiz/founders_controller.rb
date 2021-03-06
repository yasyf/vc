class External::VCWiz::FoundersController < External::FrontendController
  before_action :check_founder!, except: [:unsubscribe]

  def unsubscribe
    founder = params[:token].present? ? Founder.where(token: params[:token]).first! : current_external_founder
    if founder.present?
      founder.update! unsubscribed: true
      flash_warning 'You will no longer receive weekly updates.'
    end
    redirect_to action: :discover, controller: :vcwiz
  end
end
