class Competitor < ApplicationRecord
  COMPETITORS = {
    'Rough Draft Ventures': Http::Rdv,
    'Y Combinator': nil,
    'First Round Capital': nil,
    'TechStars': nil,
  }

  has_and_belongs_to_many :companies, -> { distinct }
  has_many :investors

  validates :name, presence: true, uniqueness: true
  validates :crunchbase_id, presence: true, uniqueness: true

  after_create :start_crunchbase_job

  def self.create_from_name!(name)
    crunchbase_id = Http::Crunchbase::Organization.find_investor_id(name)
    from_crunchbase crunchbase_id, name if crunchbase_id.present?
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
    super options.reverse_merge(only: [:name, :description], methods: [:acronym])
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
