class Competitor < ApplicationRecord
  include Concerns::AttributeSortable

  COMPETITORS = {
    'Rough Draft Ventures': Http::Rdv,
    'Y Combinator': nil,
    'First Round Capital': nil,
    'TechStars': nil,
  }.with_indifferent_access.freeze

  FUND_TYPES = {
    seed: 'Seed',
    angel: 'Angel',
    venture: 'Venture',
    series_A: 'Series A',
    series_B: 'Series B',
  }.with_indifferent_access.freeze

  INDUSTRIES = {
    consumer: 'Consumer',
    enterprise: 'Enterprise',
    ecommerce: 'E-Commerce',
    delivery: 'Delivery',
    saas: 'SaaS',
    ai: 'AI/ML',
    robotics: 'Robotics',
    food: 'Food & Drink',
    mobile: 'Mobile',
    healthcare: 'Healthcare',
    media: 'Media',
    finance: 'Finance',
    education: 'Education',
    lifesci: 'Life Sci.',
    retail: 'Retail',
    realestate: 'Real Estate',
    travel: 'Travel',
    automotive: 'Automotive',
    sports: 'Sports',
    cleantech: 'Clean Tech',
    iot: 'IoT',
    social: 'Social',
    energy: 'Energy',
    hardware: 'Hardware',
    gaming: 'Gaming',
    space: 'Space',
    data: 'Data',
    transportation: 'Transportation',
    marketplace: 'Marketplace',
    security: 'Security',
  }.with_indifferent_access.freeze

  RELATED_INDUSTRIES = {
    saas: ['Software as a Service'],
    gaming: ['Video Games'],
    transportation: ['Public Transportation', 'Ride Sharing'],
    mobile: ['Mobile Devices', 'Telecommunications', 'Mobile Apps'],
    food: ['Food and Beverage', 'Food Delivery', 'Nutrition', 'Food', 'Restaurants'],
    social: ['Social', 'Messaging', 'Social Media'],
    ai: ['Machine Learning', 'Artificial Intelligence'],
    enterprise: ['Enterprise Software', 'B2B'],
    healthcare: ['Health Care', 'Medical'],
    media: ['Entertainment', 'Music', 'Video'],
    finance: ['FinTech'],
    energy: ['Electric Vehicle', 'Energy Management'],
    data: ['Analytics'],
    iot: ['Internet of Things'],
    security: ['Network Security', 'Cyber Security'],
  }.freeze

  CLOSEST_INDUSTRY_THRESHOLD = 0.4

  sort :industry
  sort :fund_type
  sort :location

  has_many :investors, dependent: :destroy
  has_many :target_investors, through: :investors
  has_many :investments, dependent: :destroy
  has_many :companies, through: :investments
  has_many :notes, as: :subject, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :crunchbase_id, uniqueness: { allow_nil: true }
  validates :al_id, uniqueness: { allow_nil: true }

  after_commit :start_crunchbase_job, on: :create

  def self.closest_industry(industry)
    distances = INDUSTRIES.flat_map do |k, friendly|
      ([friendly] + (RELATED_INDUSTRIES[k] || [])).map do |s|
        [Levenshtein.distance(s, industry) / [k.length, industry.length].max.to_f, k]
      end
    end
    if (best = distances.sort.first).first < CLOSEST_INDUSTRY_THRESHOLD
      best.last
    else
      nil
    end
  end

  def self.create_from_name!(name)
    existing = search(name: name).first
    return existing if existing.present?

    if (crunchbase_id = Http::Crunchbase::Organization.find_investor_id(name)).present?
      from_crunchbase! crunchbase_id, name
    elsif (al_id = Http::AngelList::Startup.find_id(name))
      from_angelist! al_id, name
    else
      create! name: name
    end
  end

  def self.create_from_domain!(domain, name)
    crunchbase_id = Http::Crunchbase::Organization.find_domain_id(domain)
    from_crunchbase! crunchbase_id, name if crunchbase_id.present?
  end

  def self.from_crunchbase!(crunchbase_id, name)
    found = where(crunchbase_id: crunchbase_id).or(where(name: name)).first
    found = create!(crunchbase_id: crunchbase_id, name: name) unless found.present?
    found.tap do |competitor|
      competitor.crunchbase_id = crunchbase_id
      competitor.name = name
    end
  end

  def self.from_angelist!(al_id, name)
    where(al_id: al_id).first_or_create! do |competitor|
      competitor.name = name
    end
  end

  def self.for_company(company)
    org = company.crunchbase_org(5)
    where(name: COMPETITORS.keys).select do |competitor|
        org.has_investor?(competitor.crunchbase_id) ||
        COMPETITORS[competitor.name]&.new&.invested?(company.name)
    end
  end

  def self.to_param(company)
    return false unless company.competitors.present?
    company.competitors.map(&:acronym).join(', ')
  end

  def self._filtered(params)
    competitors = if (search = params[:search]).present?
      search = { name: search, investors: { first_name: search, last_name: search } }
      search_query = Competitor.includes(:investors).references(:investors).fuzzy_search(search, false)
      subquery = "SELECT searched.id from (#{search_query.to_sql}) AS searched"
      where("competitors.id IN (#{subquery})")
    else
      all
    end
    %w(industry fund_type location).each do |param|
      next unless params[param].present?
      competitors = competitors.where("competitors.#{param} && ?", "{#{params[param]}}")
    end
    competitors = competitors.joins(:companies).where('companies.id': params[:companies].split(',')) if params[:companies].present?
    competitors
  end

  def self.filtered(params)
    filtered = _filtered(params)
    filtered = filtered.left_outer_joins(:companies) unless params[:companies].present?
    filtered
      .group('competitors.id')
      .order('count(investors.featured) DESC, count(investors.target_investors_count) DESC, count(companies.id) DESC')
      .joins('LEFT OUTER JOIN investors ON investors.competitor_id = competitors.id')
      .joins('LEFT OUTER JOIN (SELECT target_investors.investor_id, target_investors.stage FROM target_investors ORDER BY target_investors.updated_at DESC LIMIT 1) AS stages ON stages.investor_id = investors.id')
      .select('competitors.*, min(stages.stage) as track_status')
  end

  def self.filtered_count(params)
    _filtered(params).count
  end

  def self.locations(query, limit = 5)
    connection.select_values """
      SELECT * from (
        SELECT unnest(locations) from (
          SELECT location from competitors WHERE location <> '{}' AND location IS NOT NULL
        ) AS s(locations)
      ) AS s(ulocations)
      WHERE ulocations ILIKE '#{query.present? ? sanitize_sql_like(query) : ''}%'
      GROUP BY ulocations
      ORDER BY count(ulocations) DESC
      LIMIT #{limit}
    """
  end

  def as_json(options = {})
    super options.reverse_merge(
      only: [
        :industry,
        :name,
        :fund_type,
        :location,
        :photo,
      ],
      methods: [
        :acronym,
        :track_status
      ]
    )
  end

  def as_search_json
    as_json(only: [:name, :industry, :fund_type], methods: [])
  end

  def acronym
    name.split('').select { |l| /[[:upper:]]/.match l }.join
  end

  def crunchbase_fund
    @crunchbase_fund ||= Http::Crunchbase::Fund.new(crunchbase_id, nil)
  end

  def angellist_startup
    @angellist_startup ||= Http::AngelList::Startup.new(al_id)
  end

  private

  def track_status
    if self.attributes.key?('track_status')
      (self[:track_status] && TargetInvestor::STAGES.keys[self[:track_status]])
    else
      target_investors.order(updated_at: :desc).limit(1).pluck(:stage).first
    end
  end

  def start_crunchbase_job
    CompetitorCrunchbaseJob.perform_later(id)
  end
end
