class Company < ActiveRecord::Base
  include Concerns::Cacheable
  include ActionView::Helpers::NumberHelper
  include Concerns::AttributeSortable

  has_one :tweeter
  has_many :pitches
  has_many :cards
  has_many :calendar_events
  belongs_to :team
  has_and_belongs_to_many :users, -> { distinct }
  has_and_belongs_to_many :competitors, -> { distinct }
  has_and_belongs_to_many :founders, -> { distinct }

  validates :name, presence: true

  validates :domain, uniqueness: { allow_nil: true }
  validates :crunchbase_id, uniqueness: { allow_nil: true }
  validates :capital_raised, presence: true, numericality: { only_integer: true }

  sort :industry

  scope :pitched, -> { joins(:pitches) }
  scope :decided, -> { pitched.where('pitches.decision IS NOT NULL') }
  scope :undecided, -> { pitched.where('pitches.decision IS NULL') }
  scope :portfolio, -> { pitched.where('pitches.funded': true) }

  after_create :add_to_wit!
  after_commit :start_relationships_job, on: :create

  def pitch
    @pitch ||= pitches.order(when: :desc).first
  end

  def card
    @card ||= cards.where(archived: false).order(updated_at: :desc).first
  end

  def domain=(domain)
    parsed = begin
      URI.parse(domain).host
    rescue URI::InvalidURIError
      domain
    end
    parsed = parsed[4..-1] if parsed.starts_with?('www.')
    super parsed
  end

  def in_list?(list)
    card.present? ? card.list.in?(Array.wrap(list)) : false
  end

  def passed?
    team.present? && in_list?([team.lists.rejected, team.lists.passed])
  end

  def funded?
    pitch&.funded? || (team.present? && in_list?(team.funded_lists))
  end

  def pitched?
    pitch.present? && pitch.pitched?
  end

  def partner_names
    cached { users.map(&:name) }
  end

  def self.sync!(quiet: true, deep: false)
    Team.for_each do |team|
      TeamCompanySyncJob.perform_later(team, deep: deep, quiet: quiet)
    end
  end

  def capital_raised(format: false)
    format ? number_to_human(super(), locale: :money) : super()
  end

  def add_user(user)
    card.add_user user
    users << user
    save!
  end

  def add_comment!(comment, notify: false)
    return unless team.present?
    card.add_comment! comment
    team.notify!(comment, all: false) if notify
  end

  def as_json(options = {})
    super options.reverse_merge(only: [:name, :description, :industry], methods: [:complete?])
  end

  def as_json_api(options = {})
    options.reverse_merge!(
      methods: [:competitors],
      only: [
        :id,
        :name,
        :domain,
        :description,
      ]
    )
    key_cached(
      options.slice(:methods, :only, :except, :root, :include),
      cache_unless_voting(expires_in: jitter(1, :day)),
    ) do
      pitch_on = pitch.when.to_time.to_i if pitch.present?
      super(options).merge(
        capital_raised: capital_raised(format: true),
        pitch_on: pitch_on,
        funded: funded?,
        passed: passed?,
        past_deadline: pitch&.past_deadline?,
        pitched: pitched?,
        partners: users.map { |user| { name: user.name, slack_id: user.slack_id }  },
        trello_url: card&.trello_url,
        stats: pitch&.stats,
        trello_id: card&.trello_id,
        snapshot_link: pitch&.snapshot,
      )
    end
  end

  def set_extra_attributes!
    pitch&.set_snapshot!
    set_crunchbase_attributes!
    set_competitors!
    set_capital_raised!
  end

  def invalidate_crunchbase_id!
    self.crunchbase_id = "#{Http::Crunchbase::Organization::INVALID_KEY}_#{param_name}"
    self.domain = nil
    self.description = nil
    self.capital_raised = funded? ? 20_000 : 0
    save!
  end

  def param_name
    name.gsub(' ', '').parameterize
  end

  def team
    return nil unless (cached_team = super).present?
    Team.send(cached_team.name)
  end

  def crunchbase_org(timeout = 2)
    @crunchbase_org ||= Http::Crunchbase::Organization.new(self, timeout)
  end

  def cb_slack_link
    "<#{crunchbase_org.crunchbase_url}|#{name}>"
  end

  def tweeter
    super || (create_tweeter!(username: twitter_username) if twitter_username.present?)
  end

  def self.searchable_columns
    [:name]
  end

  def self.from_domain(domain)
    existing = Company.where(domain: domain)
    return existing.first if existing.present?

    id = Http::Crunchbase::Organization.find_domain_id(domain, types: 'company')
    Company.where(crunchbase_id: id).first_or_initialize.tap do |company|
      company.domain = domain
    end
  end

  def self.from_founder(founder)
    company = from_domain founder.domain
    if (org = company.crunchbase_org).found?
      company.name = org.name
      company.description = org.description
    else
      company.name = "#{founder.name} NewCo"
      company.skip_job!
    end
    company.save!
    company
  end

  def skip_job!
    @skip_job = true
  end


  def complete?
    name.present? && description.present? && industry.present?
  end

  private

  def cache_unless_voting(options = {})
    options[:force] = true if pitches.where(decision: nil).present?
    options
  end

  def start_relationships_job
    CompanyRelationshipsJob.perform_later(id) unless @skip_job
  end

  def twitter_username
    cached { crunchbase_org.twitter }
  end

  def set_crunchbase_attributes!(timeout: 5)
    org = crunchbase_org(timeout)
    return unless org.permalink
    self.crunchbase_id = org.permalink
    self.domain = org.url
    self.description = org.description
  end

  def set_competitors!
    self.competitors += Competitor.for_company(self)
  end

  def set_capital_raised!
    self.capital_raised = [crunchbase_org(5).total_funding.to_i || 0, funded? ? 20_000 : 0].max
  end

  def add_to_wit!
    Http::Wit::Entity.new('company').add_value name
  end
end
