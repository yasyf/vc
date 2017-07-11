class Investor < ApplicationRecord
  belongs_to :competitor
  has_many :target_investors

  validates :competitor, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, uniqueness: { allow_nil: true }
  validates :crunchbase_id, uniqueness: { allow_nil: true }

  def self.from_crunchbase(cb_id)
    return nil unless cb_id.present?
    where(crunchbase_id: cb_id).first_or_create! do |investor|
      person = Http::Crunchbase::Person.new(cb_id)
      investor.first_name = person.first_name
      investor.last_name = person.last_name
      investor.role = person.affiliation.role
      investor.competitor = Competitor.from_crunchbase!(person.affiliation.permalink, person.affiliation.name)
      investor.description = person.short_bio
    end
  end

  def self.from_name(name)
    from_crunchbase(Http::Crunchbase::Person.find_investor_id(name))
  end

  def self.searchable_columns
    [:first_name, :last_name]
  end

  def as_json(options = {})
    super options.reverse_merge(only: [:id, :role, :first_name, :last_name, :description, :industry], methods: [:competitor])
  end

  def crunchbase_person
    @crunchbase_person ||= Http::Crunchbase::Person.new(crunchbase_id) if crunchbase_id.present?
  end
end
