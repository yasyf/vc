class External::VcwizController < External::ApplicationController
  include External::ApplicationHelper

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
    props(
      competitors: Competitor.filtered(filter_params).limit(10),
      count: Competitor.filtered_count(filter_params),
      filters: full_filters,
    )
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

  def full_filters
    {}.tap do |filters|
      filters[:fund_type] = hash_to_options(Competitor::FUND_TYPES.slice(*filter_params[:fund_type].split(','))) if filter_params[:fund_type].present?
      filters[:industry] = hash_to_options(Competitor::INDUSTRIES.slice(*filter_params[:industry].split(','))) if filter_params[:industry].present?
      filters[:location] = arr_to_options(filter_params[:location].split(',')) if filter_params[:location].present?
      filters[:companies] = records_to_options(Company.find(filter_params[:companies].split(',')).map(&:as_json_search)) if filter_params[:companies].present?
      puts('FILTERS', filters.to_s)
    end
  end
end
