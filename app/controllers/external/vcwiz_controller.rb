class External::VcwizController < External::ApplicationController
  include External::Concerns::Filterable
  include External::Concerns::Sortable
  include External::ApplicationHelper
  include External::ReactServerHelper

  layout 'vcwiz'
  before_action :check_founder!, only: [:outreach]

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
    props(
      competitors: filtered(sort: sorts, limit: 20, meta: true),
      count: filtered_count,
      filters: full_filters,
      options: options_params.to_h,
      sort: sorts,
      search: filter_params[:search],
      advanced: advanced?
    )
    render_default
  end

  def list
    title list_from_name.title
    component 'List'
    props list: list_from_name.as_json(limit: 10, meta: true)
    render_default
  end

  def outreach
    current_external_founder.ensure_target_investors!

    targets = current_external_founder
      .target_investors
      .includes(*External::Api::V1::TargetInvestorsController::INCLUDES)
      .order(updated_at: :desc)
      .limit(10)
      .as_json

    title 'Outreach'
    component 'Outreach'
    props(
      targets: targets,
      count: current_external_founder.target_investors.count,
      sort: sorts,
    )
    render_default
  end

  def signup
    session[:signup_data] = signup_params
    cookies.permanent[:login_domain] = signup_params[:domain]
    store_location_for(:external_founder, request.referer)
    redirect_login
  end

  def login
    redirect_login
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
    @component_props = props.keep_if { |k, v| !v.nil? }
  end

  def render_default
    render html: '', layout: 'vcwiz'
  end

  def redirect_login
    redirect_to omniauth_path('google_external', hd: cookies[:login_domain] || '*')
  end

  def advanced?
    params[:advanced] == 'true' if params[:advanced].present?
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

  def signup_params
    params.permit(:fund_type, :industry, :location, :companies, :name, :description, :domain)
  end

  def full_filters
    {}.tap do |filters|
      filters[:fund_type] = hash_to_options(Util.split_slice(filter_params[:fund_type], Competitor::FUND_TYPES)) if filter_params[:fund_type].present?
      filters[:industry] = hash_to_options(Util.split_slice(filter_params[:industry], Competitor::INDUSTRIES)) if filter_params[:industry].present?
      filters[:location] = arr_to_options(filter_params[:location].split(',')) if filter_params[:location].present?
      filters[:companies] = records_to_options(Company.find(filter_params[:companies].split(',')).map(&:as_json_search)) if filter_params[:companies].present?
    end
  end
end
