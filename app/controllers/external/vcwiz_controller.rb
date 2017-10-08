class External::VcwizController < External::ApplicationController
  layout 'vcwiz'
  before_action :check_founder!, except: [:opt_in, :decide]

  def index
    redirect_to action: :discover
  end

  def discover
    title 'Discover'
    component 'Discover'
    render_default
  end

  def filter
    title 'Filter'
    component 'Filter'
    puts filter_params.to_s
    props competitors: Competitor.filtered(filter_params).limit(25), count: Competitor.filtered_count(filter_params)
    render_default
  end

  def opt_in
    intro_request.investor.update! opted_in: optin?
    intro_request.decide! accept?
  end

  def decide
    intro_request.decide! accept?
  end

  private

  def title(title)
    @title = title
  end

  def component(name)
    @component_name = name
  end

  def props(props)
    @component_props = props
  end

  def render_default
    render html: '', layout: 'vcwiz'
  end

  def optin?
    params[:optin] == 'true'
  end

  def accept?
    params[:accept] == 'true'
  end

  def intro_request
    @intro_request ||= IntroRequest.where(token: params[:token]).first!
  end

  def filter_params
    params.permit(:industry, :location, :fund_type, :companies, :similar)
  end
end
