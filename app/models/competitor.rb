class Competitor < ApplicationRecord
  include Concerns::AttributeSortable
  include Concerns::Domainable

  COMPETITORS = {
    'Rough Draft Ventures': Http::Rdv,
    'Y Combinator': nil,
    'First Round Capital': nil,
    'TechStars': nil,
  }.with_indifferent_access.freeze

  FUND_TYPES = {
    accelerator: 'Accelerator',
    angel: 'Angel',
    seed: 'Seed',
    series_A: 'Series A',
    series_B: 'Series B',
    venture: 'Venture',
  }.with_indifferent_access.freeze

  INDUSTRIES = {
    arvr: 'AR/VR',
    bitcoin: 'Bitcoin',
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
    government: 'Government',
    legal: 'Legal',
  }.with_indifferent_access.freeze

  RELATED_INDUSTRIES = {
    arvr: ['Augmented Reality', 'Virtual Reality'],
    bitcoin: ['Blockchain', 'Virtual Currency'],
    saas: ['Software as a Service'],
    gaming: ['Video Games'],
    transportation: ['Public Transportation', 'Ride Sharing'],
    mobile: ['Mobile Devices', 'Telecommunications', 'Mobile Apps'],
    food: ['Food and Beverage', 'Food Delivery', 'Nutrition', 'Food', 'Restaurants'],
    social: ['Social', 'Messaging', 'Social Media'],
    ai: ['Machine Learning', 'Artificial Intelligence', 'Big Data'],
    enterprise: ['Enterprise Software', 'B2B'],
    healthcare: ['Health Care', 'Medical', 'Biotechnology', 'Pharmaceutical', 'Personal Health'],
    media: ['Entertainment', 'Music', 'Video', 'Photography'],
    finance: ['FinTech', 'Financial Services'],
    energy: ['Electric Vehicle', 'Energy Management'],
    data: ['Analytics'],
    iot: ['Internet of Things'],
    security: ['Network Security', 'Cyber Security'],
    government: ['GovTech'],
  }.with_indifferent_access.freeze

  INVESTOR_TITLE = %w(Managing Partner Director Associate Principal CEO Founder Invest).map(&:downcase)

  CLOSEST_INDUSTRY_THRESHOLD = 0.4

  sort :industry
  sort :fund_type
  sort :location

  has_many :investors
  has_many :target_investors, through: :investors
  has_many :investments, dependent: :destroy
  has_many :companies, through: :investments
  has_many :notes, as: :subject, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :crunchbase_id, uniqueness: { allow_nil: true }
  validates :al_id, uniqueness: { allow_nil: true }

  after_commit :start_crunchbase_job, on: :create
  before_validation :normalize_location

  def self.full_industry_options
    INDUSTRIES.map { |k, v| { value: k, other_labels: RELATED_INDUSTRIES[k], label: v } }
  end

  def self.closest_industry(industry)
    return nil unless industry.present?
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
    return nil unless domain.present?
    where(domain: domain).first_or_initialize.tap do |i|
      i.crunchbase_id ||= Http::Crunchbase::Organization.find_domain_id(domain)
      i.name = name
      i.save!
    end
  end

  def self.from_crunchbase!(crunchbase_id, name)
    return nil unless crunchbase_id.present?
    found = where(crunchbase_id: crunchbase_id).or(where(name: name)).first
    found = create!(crunchbase_id: crunchbase_id, name: name) unless found.present?
    found.tap do |competitor|
      competitor.crunchbase_id = crunchbase_id
      competitor.name = name
    end
  end

  def self.from_angelist!(al_id, name)
    return nil unless al_id.present?
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


  def self.filtered(founder, request, params, opts = {})
    CompetitorLists::Filtered.new(founder, request, params).results(**opts)
  end

  def self.filtered_count(founder, request, params)
    CompetitorLists::Filtered.new(founder, request, params).result_count
  end

  def self.locations(query, limit = 5)
    connection.select_values <<-SQL
      SELECT ulocations FROM (
        SELECT unnest(location)
        FROM competitors
        WHERE
          location <> '{}'
          AND location IS NOT NULL
      ) AS s(ulocations)
      WHERE ulocations ILIKE '#{query.present? ? sanitize_sql_like(query) : ''}%'
      GROUP BY ulocations
      ORDER BY COUNT(ulocations) DESC
      #{limit.present? ? "LIMIT #{limit}" : ''}
    SQL
  end

  def self.lists(founder, request)
    lists = CompetitorLists::Base::Base.get_eligibles(founder, request)
    Parallel.map(lists, in_threads: lists.length) do |list|
      ActiveRecord::Base.connection_pool.with_connection do
        list.new(founder, request).as_json(json: :list)
      end
    end.select { |l| l[:competitors].present? }
  end

  def self.list(founder, request, name)
    CompetitorLists::Base::Base.get_if_eligible(founder, request, name)&.new(founder, request)
  end


  def self.param_list(founder, request, name, cache_values)
    CompetitorLists::Base::Base.get(name).new(founder, request).tap do |list|
      list.cache_values = cache_values.symbolize_keys
    end
  end

  def as_json(options = {})
    super options.reverse_merge(
      only: [
        :industry,
        :name,
        :fund_type,
        :location,
        :photo,
        :facebook,
        :twitter,
      ],
      methods: [
        :acronym,
      ]
    )
  end

  def as_meta_json
    as_json(
      only: [
        :id,
        :name,
        :location,
        :photo,
        :meta,
        :description,
        :industry,
        :fund_type,
        :domain,
        :facebook,
        :twitter,
        :partners,
        :al_url,
        :crunchbase_id,
        :matches,
      ],
      methods: [
        :hq,
        :acronym,
        :recent_investments,
        :cb_url,
      ].compact
    )
  end

  def hq
    super || location&.first
  end

  def as_list_json
    as_json(only: [:photo, :id], methods: [:acronym])
  end

  def as_search_json
    as_json(only: [:name, :industry, :fund_type], methods: [])
  end

  def acronym
    name.split('').select { |l| /[[:upper:]]|\d/.match l }.join
  end

  def crunchbase_fund
    @crunchbase_fund ||= Http::Crunchbase::Fund.new(crunchbase_id, nil)
  end

  def angellist_startup
    @angellist_startup ||= Http::AngelList::Startup.new(al_id)
  end

  def cb_url
    "https://www.crunchbase.com/organization/#{crunchbase_id}" if crunchbase_id.present?
  end

  private

  def normalize_location
    self.location = self.location.map(&Util.method(:normalize_city)) if self.location.present?
  end

  def recent_investments
    if self.attributes.key?('recent_investments')
      self[:recent_investments]
    else
      companies
        .group('companies.id', 'investments.featured', 'investments.funded_at')
        .joins(:investments)
        .order('investments.featured DESC, companies.capital_raised DESC', 'count(investments.id) DESC', 'investments.funded_at DESC NULLS LAST')
        .limit(5)
    end
  end

  def start_crunchbase_job
    CompetitorCrunchbaseJob.perform_later(id)
  end
end
