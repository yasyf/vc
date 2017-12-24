class External::VCWiz::VCWizController < External::ApplicationController
  include External::Concerns::Filterable
  include External::Concerns::Sortable
  include External::Concerns::Reactable
  include External::Concerns::Censorable
  include External::ApplicationHelper

  filter %w(email)

  layout 'vcwiz'
  before_action :check_founder!, only: [:outreach]

  def index
    redirect_to action: :discover
  end

  def privacy
    render layout: 'external'
  end

  def firm
    competitor = Competitor.find(params[:id])
    list = CompetitorLists::Single.new(current_external_founder, request, params[:id])

    title list.title
    description list.description
    canonical_href external_vcwiz_firm_url(id: competitor.id, slug: competitor.name.parameterize)
    component 'CompetitorPage'
    props item: list.results(meta: true).first
    render_default
  end


  def investor
    investor = Investor.find(params[:id])

    title "#{investor.name} on VCWiz"
    description "Learn about #{investor.name} on VCWiz. #{(investor.description || '').squish.truncate(100)}"
    canonical_href external_vcwiz_investor_url(id: investor.id, slug: investor.name.parameterize)
    component 'InvestorPage'
    props item: censor(investor)
    render_default
  end

  def discover
    if params[:new_login].present? || session[:new_login]
      session.delete(:new_login)
      props is_new_login: true
    end
    if session[:open_signup]
      session.delete(:open_signup)
      props open_signup: true
    end
    company = current_external_founder&.primary_company

    title 'Discover'
    default_description
    component 'Discover'
    params.merge!(
      options: { us_only: true },
      filters: {
        fund_type: 'seed',
        industry: company&.industry&.join(','),
        location: Util.hub_city(session, current_external_founder),
        companies: company&.competitions&.map(&:id)&.join(',')
      },
    )
    apply_suggestions!
    result_props 5
    render_default
  end

  def filter
    title 'Filter'
    description "View #{description_from_filters} on VCWiz, the easiest way to discover investors that are relevant to your startup."
    component 'Filter'
    result_props 20
    render_default
  end

  def search
    title 'Search'
    description "View #{description_from_search} on VCWiz, the easiest way to discover investors that are relevant to your startup."
    component 'Search'
    result_props 20
    render_default
  end

  def list
    path = list_external_api_v1_competitors_path(list: list_from_name.to_param, key: params[:key], value: params[:value])
    description "#{list_from_name.title} on VCWiz. #{list_from_name.description}"
    title list_from_name.title.titleize
    component 'List'
    props list: list_from_name.as_json(limit: 10, meta: true), path: path
    render_default
  end

  def outreach
    flash_warning 'VCWiz is still processing your inbox. Check back soon!' if current_external_founder.scanner_pending?
    current_external_founder.ensure_target_investors!

    targets = current_external_founder
      .target_investors
      .includes(*External::Api::V1::TargetInvestorsController::INCLUDES)
      .order(stage: :asc, updated_at: :desc)
      .limit(10)
      .as_json

    title 'Outreach'
    default_description
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
    redirect_login
  end

  def login
    redirect_login
  end

  def gmail_auth
    redirect_gmail
  end

  private

  def canonical_href(href)
    @canonical = href
  end

  def render_default
    render html: '', layout: 'vcwiz'
  end

  def redirect_gmail
    store_location_for(:external_founder, external_vcwiz_outreach_path)
    redirect_to omniauth_path('gmail', login_hint: current_external_founder.email)
  end

  def redirect_login
    store_location_for(:external_founder, request.referer) if URI::parse(request.referer).host == ENV['SITE_DOMAIN']
    redirect_to omniauth_path(enable_scanner? ? 'gmail' : 'google_external', hd: params[:domain] || cookies[:login_domain] || '*')
  end

  def enable_scanner?
    signup_params[:enable_scanner] == 'true'
  end

  def signup_params
    params.permit(:fund_type, :industry, :location, :companies, :name, :description, :domain, :enable_scanner)
  end

  def description_from_filters
    filters = filter_params[:filters]
    fund_types = filters[:fund_type].present? && Util.split_slice( filters[:fund_type], Competitor::FUND_TYPES).values.to_sentence
    industries = filters[:industry].present?  && Util.split_slice(filters[:industry], Competitor::INDUSTRIES).values.to_sentence
    locations  = filters[:location].present?  && filters[:location].split(',').to_sentence
    companies  = filters[:companies].present? && Company.find(filters[:companies].split(',')).map(&:name).to_sentence
    [
      fund_types || nil,
      'venture firms',
      locations ? "located in #{locations}" : nil,
      industries ? "who invest in #{industries}" : nil,
      companies ? "#{industries ? 'and ' : ''}who invested in #{companies}" : nil,
    ].compact.join(' ')
  end

  def description_from_search
    search = search_params[:search]
    [
      search[:first_name].present? ? search[:first_name].titleize : nil,
      search[:last_name].present? ? search[:last_name].titleize : nil,
      search[:first_name].present? || search[:last_name].present? ? nil : 'Investors',
      search[:firm_name].present? ? "at #{search[:firm_name].titleize}" : nil,
    ].compact.join(' ')
  end

  def default_description
    description 'VCWiz is the easiest way to discover the investors that are relevant to your startup, research firms, get introduced, and keep track of your conversations with investors.'
  end

  def full_filters
    from_params = filter_params[:filters]
    {}.tap do |filters|
      filters[:fund_type] = hash_to_options(Util.split_slice(from_params[:fund_type], Competitor::FUND_TYPES)) if from_params[:fund_type].present?
      filters[:industry] = hash_to_options(Util.split_slice(from_params[:industry], Competitor::INDUSTRIES)) if from_params[:industry].present?
      filters[:location] = arr_to_options(from_params[:location].split(',')) if from_params[:location].present?
      filters[:companies] = records_to_options(Company.find(from_params[:companies].split(',')).map(&:as_json_search)) if from_params[:companies].present?
    end
  end

  def result_props(limit)
    props(
      competitors: filtered_results(sort: sorts, limit: limit, meta: true),
      count: filtered_count,
      suggestions: filtered_suggestions,
      filters: full_filters,
      options: options_params[:options].to_h,
      sort: sorts,
      search: search_params[:search].to_h,
    )
  end
end
