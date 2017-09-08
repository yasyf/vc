class Investor < ApplicationRecord
  include Concerns::AttributeSortable
  include Concerns::Cacheable
  include Concerns::Twitterable

  GENDERS = %w(unknown male female)

  belongs_to :competitor
  has_many :target_investors
  has_many :notes, as: :subject
  has_many :investments, class_name: 'CompaniesCompetitor'
  has_many :companies, through: :investments
  belongs_to :university
  has_many :news
  has_many :person_entities, as: :person
  has_many :entities, through: :person_entities

  validates :competitor, presence: true
  validates :first_name, presence: true, uniqueness: { scope: [:last_name, :competitor_id] }
  validates :last_name, presence: true
  validates :email, uniqueness: { allow_nil: true }
  validates :crunchbase_id, uniqueness: { allow_nil: true }
  validates :al_id, uniqueness: { allow_nil: true }
  validates :facebook, uniqueness: { allow_nil: true }
  validates :linkedin, uniqueness: { allow_nil: true }
  validates :twitter, uniqueness: { allow_nil: true }
  validates :homepage, uniqueness: { allow_nil: true }

  sort :industry
  sort :fund_type
  enum gender: GENDERS

  before_save :titleize_role
  after_commit :start_crunchbase_job, on: :create

  def name
    "#{first_name} #{last_name}"
  end

  def populate_from_cb!
    person = crunchbase_person
    return unless person.present? && person.found?

    self.first_name = person.first_name
    self.last_name = person.last_name
    self.role = person.affiliation.role
    self.competitor = Competitor.from_crunchbase!(person.affiliation.permalink, person.affiliation.name)
    self.description = person.bio
    self.photo = person.image
    self.location = person.location&.name
    self.gender = person.gender || self.gender
    self.university = University.from_name(person.university) if person.university.present?

    person.affiliated_companies.each do |company|
      scope = self.competitor.companies
      company = scope.where(crunchbase_id: company['permalink']).or(scope.where(name: company['name'])).first
      next unless company.present?
      assign_company! company
    end

    person.news.each do |news|
      news = begin
        News.where(investor: self, url: news['url']).first_or_create!(title: news['title'])
      rescue ActiveRecord::RecordInvalid
        next
      end
      self.competitor.companies.find_each do |company|
        if news.page.to_s.include?(company.name)
          news.update! company: company
          assign_company! company
        end
      end
    end

    Founder::SOCIAL_KEYS.each do |attr|
      self[attr] = person.public_send(attr)
    end

    if self.homepage.present?
      body = HTTParty.get(self.homepage).body
      self.entities += Entity.from_html(body)
      self.competitor.companies.find_each do |company|
        if body.include?(company.name)
          assign_company! company
        end
      end
    end
  end

  def populate_from_al!
    return unless angelist_user.present? && angelist_user.found?

    name = angelist_user.name.split(' ')
    self.first_name ||= name.first
    self.last_name ||= name.drop(1).join(' ')

    self.photo = angelist_user.image
    self.twitter = angelist_user.twitter
    self.facebook = angelist_user.facebook
    self.linkedin = angelist_user.linkedin

    self.description ||= angelist_user.bio
    self.homepage ||= angelist_user.homepage
    self.location ||= angelist_user.locations.first

    if angelist_user.fund_types.present?
      self.fund_type = (self.fund_type || []) + angelist_user.fund_types
    end
  end

  def assign_company!(company)
    CompaniesCompetitor.assign_to_investor(self, company)
  end

  def set_gender!
    return unless self.gender == :unknown
    gender = GenderDetector.new.get_gender(self.first_name)
    self.gender = gender if gender.in?(GENDERS)
  end

  def self.from_crunchbase(cb_id)
    return nil unless cb_id.present?
    where(crunchbase_id: cb_id).first_or_create! do |investor|
      investor.populate_from_cb!
    end
  rescue ActiveRecord::RecordInvalid
    nil
  end

  def self.from_angelist(al_id)
    return nil unless al_id.present?
    where(al_id: al_id).first_or_create! do |investor|
      investor.populate_from_al!
    end
  rescue ActiveRecord::RecordInvalid
    nil
  end

  def self.from_name(name)
    existing = fuzzy_search(first_name: name, last_name: name).first
    return existing if existing.present?
    created = from_crunchbase(Http::Crunchbase::Person.find_investor_id(name))
    return created if created.present?
    from_angelist(Http::AngelList::User.find_id(name))
  end

  def self.searchable_columns
    [:first_name, :last_name]
  end

  def self.locations
    Rails.cache.fetch('Investor/locations', { expires_in: 1.day }) do
      where.not(location: nil).group('location').order('count(*) DESC').pluck('location')
    end
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
        :fund_type,
        :industry_highlight,
        :photo,
        :twitter,
        :facebook,
        :linkedin,
        :homepage,
        :location,
        :email,
      ],
     methods: [:competitor, :recent_investments, :recent_news, :university, :notes]
    )
  end

  def as_search_json
    as_json(
      only: [
        :id,
        :role,
        :first_name,
        :last_name,
        :photo,
        :industry,
        :fund_type,
      ],
      methods: [:initials],
    ).merge(competitor: competitor.as_search_json)
  end

  def crunchbase_person(raise_on_error: true)
    @crunchbase_person ||= begin
      person = Http::Crunchbase::Person.new(crunchbase_id, nil, raise_on_error)
      person if person.found?
    end if crunchbase_id.present?
  end

  def angelist_user(safe: false)
    @angelist_user ||= begin
      user = Http::AngelList::User.new al_id
      user if user.found?
    end if al_id.present?
  rescue HTTP::AngelList::Errors::RateLimited
    raise unless safe
    nil
  end

  def blog_url
    @blog_url ||= cached do
      angelist_user(safe: true)&.blog || crunchbase_person&.blog || homepage || ("https://medium.com/@#{twitter}" if twitter.present?)
    end
  end

  def posts
    cache_for_a_day do
      return [] unless blog_url.present?
      url = MetaInspector.new(blog_url).feed
      return [] unless url.present?
      body = HTTParty.get(url).body
      feed = Feedjira::Feed.parse body
      feed.entries.first(3).map do |e|
        e.to_h.with_indifferent_access.slice(:title, :url, :categories, :published)
      end
    end
  end

  def tweets(n = 3)
    return [] unless twitter.present?
    cache_for_a_hour do
      twitter_client.with_client([]) do |client|
        client.user_timeline(twitter, count: n, include_rts: false, exclude_replies: true)
      end.map do |t|
        t.to_h.with_indifferent_access.slice(:text, :created_at, :id)
      end
    end
  end

  def travel_status(city)
    if city == location
      :working
    elsif city.in?(competitor.location)
      :work_traveling
    else
      :pleasure_traveling
    end
  end

  private

  def recent_news(n = 5)
    news.order('created_at DESC').limit(n)
  end

  def recent_investments(n = 5)
    mine = investments.order('funded_at DESC').limit(n).map(&:company)
    mine.present? ? mine : competitor.recent_investments(n)
  end

  def initials
    "#{first_name.first.upcase}#{last_name.first.upcase}"
  end

  def titleize_role
    return unless self.role.present?
    self.role = self.role.titleize unless self.role.upcase == self.role
  end

  def start_crunchbase_job
    InvestorCrunchbaseJob.perform_later(id)
  end
end
