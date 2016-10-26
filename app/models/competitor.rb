class Competitor < ApplicationRecord
  COMPETITORS = {
    'Rough Draft Ventures': Http::Rdv,
    'Y Combinator': nil,
    'First Round Capital': nil,
  }

  has_and_belongs_to_many :companies

  validates :name, presence: true
  validates :crunchbase_id, presence: true

  def self.create_from_name!(name)
    crunchbase_id = Http::Crunchbase::Organization.find_investor_id(name)
    where(name: name, crunchbase_id: crunchbase_id).first_or_create!
  end

  def self.for_company(company)
    org = company.crunchbase_org(5)
    all.select do |competitor|
        org.has_investor?(competitor.crunchbase_id) ||
        COMPETITORS[competitor.name]&.new&.invested?(company.name)
    end
  end

  def self.to_param(company)
    return false unless company.competitors.present?
    company.competitors.map(&:acronym).join(', ')
  end

  def as_json(options = {})
    super options.reverse_merge(only: [:name])
  end

  def acronym
    name.split(' ').map(&:first).join('')
  end
end
