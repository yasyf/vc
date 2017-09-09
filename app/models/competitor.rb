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
    pe: 'Private Equity',
  }.with_indifferent_access.freeze

  INDUSTRIES = {
    consumer: 'Consumer',
    enterprise: 'Enterprise',
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
  }.with_indifferent_access.freeze

  RELATED_INDUSTRIES = {
    mobile: ['Mobile Devices', 'Telecommunications'],
    food: ['Food and Beverage', 'Food Delivery', 'Nutrition', 'Food'],
    social: ['Social', 'Messaging', 'Social Media'],
    ai: ['Machine Learning', 'Artificial Intelligence'],
    enterprise: ['Enterprise Software', 'B2B'],
    healthcare: ['Health Care', 'Medical'],
    media: ['Entertainment'],
    finance: ['FinTech'],
    energy: ['Electric Vehicle', 'Energy Management'],
    data: ['Analytics'],
    iot: ['Internet of Things'],
  }.freeze

  CLOSEST_INDUSTRY_THRESHOLD = 0.4

  sort :industry
  sort :fund_type
  sort :location

  has_and_belongs_to_many :companies, -> { distinct }
  has_many :investors
  has_many :notes, as: :subject
  has_many :investments, class_name: 'CompaniesCompetitor'

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

  def self.create_from_domain!(domain)
    crunchbase_id = Http::Crunchbase::Organization.find_domain_id(name)
    from_crunchbase! crunchbase_id, name if crunchbase_id.present?
  end

  def self.from_crunchbase!(crunchbase_id, name)
    where(crunchbase_id: crunchbase_id).first_or_create! do |competitor|
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

  def as_json(options = {})
    super options.reverse_merge(
      only: [
        :industry,
        :name,
        :description,
        :fund_type
      ],
      methods: [
        :acronym,
        :notes,
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

  def start_crunchbase_job
    CompetitorCrunchbaseJob.perform_later(id)
  end
end
