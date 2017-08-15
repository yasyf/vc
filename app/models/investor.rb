class Investor < ApplicationRecord
  include Concerns::AttributeSortable

  belongs_to :competitor
  has_many :target_investors
  has_many :notes, as: :subject

  validates :competitor, presence: true
  validates :first_name, presence: true, uniqueness: { scope: [:last_name, :competitor_id] }
  validates :last_name, presence: true
  validates :email, uniqueness: { allow_nil: true }
  validates :crunchbase_id, uniqueness: { allow_nil: true }
  validates :facebook, uniqueness: { allow_nil: true }
  validates :linkedin, uniqueness: { allow_nil: true }
  validates :twitter, uniqueness: { allow_nil: true }
  validates :homepage, uniqueness: { allow_nil: true }

  enum funding_size: Competitor::FUNDING_SIZES.keys
  sort :industry

  before_save :titleize_role
  after_commit :start_crunchbase_job, on: :create

  def name
    "#{first_name} #{last_name}"
  end

  def populate_from_cb!
    @skip_job = true

    person = Http::Crunchbase::Person.new(crunchbase_id)
    return unless person.found?

    self.first_name ||= person.first_name
    self.last_name ||= person.last_name
    if person.affiliation.present?
      self.role ||= person.affiliation.role
      self.competitor ||= Competitor.from_crunchbase!(person.affiliation.permalink, person.affiliation.name)
    end
    self.description ||= person.bio
    self.photo ||= person.image
    self.location ||= person.location.name

    %w(twitter facebook linkedin homepage).each do |attr|
      self[attr] = person.public_send(attr)
    end
  end

  def self.from_crunchbase(cb_id)
    return nil unless cb_id.present?
    where(crunchbase_id: cb_id).first_or_create! do |investor|
      investor.populate_from_cb!
    end
  rescue ActiveRecord::RecordInvalid
    nil
  end

  def self.from_name(name)
    existing = fuzzy_search(first_name: name, last_name: name).first
    return existing if existing.present?
    from_crunchbase(Http::Crunchbase::Person.find_investor_id(name))
  end

  def self.searchable_columns
    [:first_name, :last_name]
  end

  def as_json(options = {})
    super options.reverse_merge(
      only: [
        :id,
        :role,
        :first_name,
        :last_name,
        :description,
        :industry,
        :funding_size,
        :industry_highlight,
        :photo,
        :twitter,
        :facebook,
        :linkedin,
        :homepage,
      ],
     methods: [:competitor, :notes]
    )
  end

  def crunchbase_person
    @crunchbase_person ||= Http::Crunchbase::Person.new(crunchbase_id) if crunchbase_id.present?
  end

  def posts
    site = crunchbase_person.blog || homepage || "https://medium.com/@#{twitter}"
    return [] unless site.present?
    url = MetaInspector.new(site).feed
    return [] unless url.present?
    body = HTTParty.get(url).body
    feed = Feedjira::Feed.parse body
    feed.entries.map(&:to_h).first(3)
  end

  private

  def titleize_role
    return unless self.role.present?
    self.role = self.role.titleize unless self.role.upcase == self.role
  end

  def start_crunchbase_job
    InvestorCrunchbaseJob.perform_later(id) unless @skip_job
  end
end
