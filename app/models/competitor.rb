class Competitor < ApplicationRecord
  include Concerns::AttributeSortable

  COMPETITORS = {
    'Rough Draft Ventures': Http::Rdv,
    'Y Combinator': nil,
    'First Round Capital': nil,
    'TechStars': nil,
  }.with_indifferent_access.freeze

  FUNDING_SIZES = {
    '0': '10k to 100k',
    '1': '100k to 250k',
    '2': '250k to 500k',
    '3': 'above 500k',
  }.with_indifferent_access.freeze

  INDUSTRIES = {
    consumer: 'Consumer',
    enterprise: 'Enterprise',
    saas: 'SaaS',
    ai: 'Artificial Intelligence',
    robotics: 'Robotics',
    food: 'Food and Beverage',
    mobile: 'Mobile',
    healthcare: 'Healthcare',
    media: 'Media',
    finance: 'Finance',
    education: 'Education',
    lifesci: 'Life Sciences',
    retail: 'Retail',
    realestate: 'Real Estate',
    travel: 'Travel',
    automotive: 'Automotive',
    sports: 'Sports',
    cleantech: 'Clean Technology',
    iot: 'Internet of Things',
    social: 'Social Media',
    energy: 'Energy',
    hardware: 'Hardware',
    gaming: 'Gaming',
    space: 'Space',
    data: 'Data',
  }.with_indifferent_access.freeze

  RELATED_INDUSTRIES = {
    mobile: ['Mobile Devices', 'Telecommunications'],
    food: ['Food Delivery', 'Nutrition', 'Food'],
    social: ['Social', 'Messaging'],
    ai: ['Machine Learning'],
    enterprise: ['Enterprise Software', 'B2B'],
    healthcare: ['Health Care', 'Medical'],
    media: ['Entertainment'],
    finance: ['FinTech'],
    energy: ['Electric Vehicle', 'Energy Management'],
    data: ['Analytics'],
  }.freeze

  CLOSEST_INDUSTRY_THRESHOLD = 0.4

  enum funding_size: FUNDING_SIZES.keys
  sort :industry

  has_and_belongs_to_many :companies, -> { distinct }
  has_many :investors
  has_many :notes, as: :subject

  validates :name, presence: true, uniqueness: true
  validates :crunchbase_id, uniqueness: { allow_nil: true }

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

    crunchbase_id = Http::Crunchbase::Organization.find_investor_id(name)
    if crunchbase_id.present?
      from_crunchbase! crunchbase_id, name
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
    super options.reverse_merge(only: [:industry, :name, :description, :funding_size], methods: [:acronym, :notes])
  end

  def acronym
    name.split('').select { |l| /[[:upper:]]/.match l }.join
  end

  def crunchbase_fund
    @crunchbase_fund ||= Http::Crunchbase::Fund.new(crunchbase_id)
  end

  private

  def start_crunchbase_job
    CompetitorCrunchbaseJob.perform_later(id)
  end
end
