class Investor < ApplicationRecord
  extend Concerns::Ignorable

  include Concerns::AttributeSortable
  include Concerns::Cacheable
  include Concerns::Twitterable
  include Concerns::Ignorable
  include Concerns::TimeZonable

  GENDERS = %w(unknown male female)

  belongs_to :competitor
  has_many :target_investors, dependent: :destroy
  has_many :notes, as: :subject
  has_many :investments, dependent: :destroy
  has_many :companies, through: :investments
  belongs_to :university
  has_many :news, dependent: :destroy
  has_many :person_entities, as: :person
  has_many :entities, through: :person_entities
  has_many :emails
  has_many :posts, dependent: :destroy
  has_one :tweeter, as: :owner, dependent: :destroy

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
  before_validation :normalize_location

  def self.from_addr(addr)
    where(email: addr.address).first || search(first_name: addr.name, last_name: addr.name).first
  end

  def name
    "#{first_name} #{last_name}"
  end

  def populate_from_cb!
    person = crunchbase_person
    return unless person.present? && person.found?

    Founder::SOCIAL_KEYS.each do |attr|
      self[attr] = person.public_send(attr)
    end

    self.first_name = person.first_name
    self.last_name = person.last_name
    if person.affiliation.present?
      self.role = person.affiliation.role
      self.competitor = Competitor.from_crunchbase!(person.affiliation.permalink, person.affiliation.name) if person.affiliation.permalink.present?
    end
    self.description = person.bio
    self.photo = person.image
    self.location = person.location&.name
    self.country = person.location&.country_code2
    self.gender = person.gender || self.gender
    self.university = University.from_name(person.university) if person.university.present?

    return unless self.competitor.present?

    person.affiliated_companies.each do |company|
      scope = self.competitor.companies
      company = scope.where(crunchbase_id: company['permalink']).or(scope.where(name: company['name'])).first
      next unless company.present?
      assign_company! company, featured: true
    end

    news = person.news.map { |n| [n['url'], n] }.to_h
    Http::Fetch.get(news.keys).each do |url, body|
      next unless body.present?
      ignore_invalid { import_news_with_body(url, body, news[url]['posted_on']) }
    end
  end

  def fetch_news!
    news = Http::Bing.news("#{name} + #{competitor.name}").map { |n| [n['url'], n] }.to_h
    Http::Fetch.get(news.keys).each do |url, body|
      meta = news[url]
      import_news_with_attrs(url, body, title: meta['name'], description: meta['description'], published_at: meta['datePublished'])
    end
  end

  def set_timezone!
    return unless self.location.present?
    return unless (timezone = Http::GoogleMaps.new.timezone(self.location)).present?
    self.time_zone = timezone.name
  end

  def crawl_homepage!
    return unless self.homepage.present?
    body = Http::Fetch.get_one self.homepage
    unless body.present?
      self.homepage = nil
      return
    end
    self.entities.concat Entity.from_html(body)
    self.competitor.companies.find_each do |company|
      if body.include?(company.name)
        assign_company! company, featured: true
      end
    end
  end

  def crawl_posts!
    new_posts = fetch_posts!
    existing = Set.new Post.where(url: new_posts.map { |p| p[:url] }).pluck(:url)

    new_posts.reject { |p| existing.include? p[:url] }.each do |meta|
      body = meta[:content] || Http::Fetch.get_one(meta[:url])
      next unless body.present?
      post = begin
        posts.where(url: meta[:url]).first_or_create!(title: meta[:title], published_at: meta[:published])
      rescue ActiveRecord::RecordInvalid
        next
      end
      post.entities.concat Entity.from_html(body)
      meta[:categories].each do |category|
        entity = Entity.from_name(category)
        next unless entity.present?
        post.person_entities.where(entity: entity, person: self).first_or_create!(featured: true)
      end if meta[:categories].present?
    end
  end

  def populate_from_al!
    return unless angelist_user.present? && angelist_user.found?

    self.al_url = angelist_user.angellist_url

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

  def assign_company!(company, featured: false, no_replace: false)
    Investment.assign_to_investor(self, company, featured: featured, no_replace: no_replace)
  end

  def set_gender!
    return unless self.gender == :unknown
    gender = GenderDetector.new.get_gender(self.first_name)
    self.gender = gender if gender.in?(GENDERS)
  end

  def self.from_crunchbase(cb_id)
    return nil unless cb_id.present?
    ignore_invalid { retry_unique { where(crunchbase_id: cb_id).first_or_create! { |investor| investor.populate_from_cb! } } }
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

  def self.create_for_competitor!(competitor, first_name, last_name)
    where(competitor: competitor, first_name: first_name, last_name: last_name).first_or_create!
  end

  def self.searchable_columns
    [:first_name, :last_name]
  end

  def self.locations(query, limit = 5)
    scope = where.not(location: nil).select('location, count(investors.id) as cnt').group('location')
    scope = scope.fuzzy_search(location: query) if query.present?
    scope.order('cnt DESC').limit(limit)
    connection.select_values scope.to_sql
  end

  def opted_out?
    opted_in == false
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
        :time_zone,
        :al_url,
      ],
     methods: [
       :competitor,
       :popular_entities,
       :recent_investments,
       :recent_news,
       :university,
       :average_response_time,
       :tweets,
       :public_posts,
       :utc_offset,
     ]
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

  def crunchbase_person
    @crunchbase_person ||= begin
      person = Http::Crunchbase::Person.new(crunchbase_id, nil)
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
    @blog_url ||= cache_for_a_month do
      angelist_user(safe: true)&.blog || crunchbase_person&.blog || homepage || ("https://medium.com/@#{twitter}" if twitter.present?)
    end
  end

  def public_posts(n: 3)
    posts.order(published_at: :desc).limit(n)
  end

  def twitter=(twitter)
    super twitter.delete_prefix('@')
  end

  def tweeter
    super || (create_tweeter(username: twitter) if twitter.present?)
  end

  def tweets(n = 3)
    return [] unless tweeter.present?
    tweeter.tweets.order(tweeted_at: :desc).limit(n)
  end

  def scrape_tweets!
    return unless tweeter.present?
    return if tweeter.private?
    tweeter.latest_tweets
  rescue Twitter::Error::Unauthorized # private account
    tweeter.update! private: true
    nil
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

  def average_response_time
    cache_for_a_week { Util.average_response_time(emails, :founder_id) }
  end

  def founder_overlap(founder)
    founder.entities.where(id: popular_entities(50))
  end

  def review
    cached do
      url = URI.escape "http://ec2-18-216-2-35.us-east-2.compute.amazonaws.com/api/investors/search?name=#{name}"
      value = HTTP::Fetch.get_one(url)
      return nil unless value.present?
      response = JSON.parse(value).with_indifferent_access
      return nil if response[:errors].present?
      return nil if response[:review].blank? || !response[:review][:published] || response[:review][:overall] < 4
      response[:review][:comment]
    end
  end

  private

  def normalize_location
    self.location = Util.normalize_city(self.location) if self.location.present?
  end

  def import_news_with_attrs(url, body, attrs)
    news = News.where(investor: self, url: url).first_or_initialize(attrs).tap do |news|
      news.body = body
      news.save!
    end
    import_news news
  end

  def import_news_with_body(url, body, published_at)
    news = News.create_with_body(url, body, investor: self, attrs: { published_at: published_at })
    import_news news
  end

  def import_news(news)
    self.competitor.companies.find_each do |company|
      if news.body.include?(company.name)
        news.update! company: company
        assign_company! company, no_replace: true
      end
    end
  end

  def fetch_posts!
    return [] unless blog_url.present?
    body = Http::Fetch.get_one blog_url
    return [] unless body.present?
    feed_url = MetaInspector.new(blog_url, document: body).feed
    return [] unless feed_url.present?
    feed_body = Http::Fetch.get_one feed_url
    return [] unless feed_body.present?
    feed = begin
      Feedjira::Feed.parse feed_body
    rescue Feedjira::NoParserAvailable
      return []
    end
    feed.entries.map do |e|
      e.to_h.with_indifferent_access.slice(:title, :url, :categories, :published, :content)
    end
  end

  def recent_news(n = 5)
    news.order('published_at DESC, created_at DESC').limit(n)
  end

  def popular_entities(n = 3)
    popular = post_entities(n)
    return popular unless (count = popular.count) < n
    Entity.where(id: entities.order(person_entities_count: :desc).limit(n - count)).or(popular)
  end

  def post_entities(n = 3)
    threshold = (posts.joins(:entities).count * 0.05).to_i
    ids = posts
      .joins(:entities)
      .group('entities.id')
      .order('count(*) DESC')
      .having('count(*) >= ?', threshold)
      .limit(n)
      .select('entities.id')
    Entity.where(id: ids)
  end

  def recent_investments(n = 3)
    companies
      .group('companies.id')
      .joins(:investments)
      .order('bool_or(investments.featured) DESC, companies.capital_raised DESC', 'count(investments.id) DESC', 'MAX(investments.funded_at) DESC NULLS LAST')
      .select('companies.*', 'MAX(investments.funded_at)')
      .limit(n)
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
