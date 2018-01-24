class Investor < ApplicationRecord
  extend Concerns::Ignorable
  include Concerns::AttributeArrayable
  include Concerns::Cacheable
  include Concerns::Twitterable
  include Concerns::Ignorable
  include Concerns::TimeZonable
  include Concerns::Locationable
  include Concerns::Graphable
  include Concerns::Socialable

  GENDERS = %w(unknown male female)

  belongs_to :competitor
  has_many :target_investors, dependent: :nullify
  has_many :notes, as: :subject
  has_many :investments, dependent: :destroy
  has_many :companies, through: :investments
  belongs_to :university
  has_many :news, dependent: :destroy
  has_many :person_entities, as: :person
  has_many :entities, through: :person_entities
  has_many :emails
  has_many :posts, dependent: :destroy
  has_many :intro_requests
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
  validates :photo, uniqueness: { allow_nil: true }

  array :industry
  array :fund_type
  enum gender: GENDERS

  before_save :titleize_role
  after_commit :start_crunchbase_job, on: :create
  after_update :check_competitor_domain
  before_validation :normalize_location, :set_first_name, :fix_linkedin!

  scope :with_token, Proc.new { |token| where.not(token: nil).where(token: token) }

  def self.from_addr(addr)
    found = where(email: addr.address).first
    return found if found.present?
    return nil unless addr.name.present?
    first, last = Util.split_name(addr.name)
    potential = search(first_name: first, last_name: last).includes(:competitor)
    return nil unless potential.present?
    potential.each do |investor|
      return investor if investor.competitor.domain == addr.domain
    end
    nil
  end

  def name
    "#{first_name} #{last_name}"
  end

  def homepage=(homepage)
    if homepage.present? && !homepage.include?('//')
      super "http://#{homepage}"
    else
      super homepage
    end
  end

  def populate_from_cb_basic!
    person = crunchbase_person
    return unless person.present? && person.found?

    self.first_name = person.first_name
    self.last_name = person.last_name
    if person.affiliation.present? && person.affiliation.investor
      self.role = person.affiliation.role
      self.competitor = Competitor.from_crunchbase!(person.affiliation.permalink, person.affiliation.name) if person.affiliation.permalink.present?
    else
      job = person.affiliated_companies.sort_by(&:updated_at).reverse.find { |job| job.organization.role_investor }
      if job.present?
        self.role = job.title
        self.competitor = Competitor.from_crunchbase!(job.organization.permalink, job.organization.name)
      end
    end
    self.description = person.bio
    self.photo = person.image
    self.location = person.location&.name
    self.country = person.location&.country_code2
    self.gender = person.gender || self.gender
    self.university = University.from_name(person.university) if person.university.present?
  end

  def populate_from_cb!
    person = crunchbase_person
    return unless person.present? && person.found?

    Founder::SOCIAL_KEYS.each do |attr|
      self[attr] = person.public_send(attr) if person.public_send(attr).present?
    end

    populate_from_cb_basic!

    return unless self.competitor.present?

    person.affiliated_companies.each do |job|
      next unless job.organization.role_company
      scope = self.competitor.companies
      company = scope.where(crunchbase_id: job.organization.permalink).or(scope.where(name: job.organization.name)).first
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
      next unless body.present?
      next unless name.downcase.in?(body.downcase) || competitor.name.downcase.in?(body.downcase)
      meta = news[url]
      import_news_with_attrs(url, body, title: meta['name'], description: meta['description'], published_at: meta['datePublished'])
    end

    Http::Newsriver.news(name, competitor.name).each do |item|
      next unless item['text'].present?
      next unless name.downcase.in?(item['text'].downcase) || competitor.name.downcase.in?(item['text'].downcase)
      body = Http::Fetch.get_one(item['url']) || item['text']
      import_news_with_attrs(item['url'], body, title: item['title'], published_at: item['discoverDate'])
    end
  end

  def set_timezone!
    return unless self.location.present?
    return unless (timezone = Http::GoogleMaps.new.timezone(self.location)).present?
    self.time_zone = timezone.name
  end

  def add_entities!(owner, entities)
    entities.each do |entity|
      ignore_unique { PersonEntity.where(person: owner, entity: entity).first_or_create! }
    end
  end

  def crawl_homepage!
    return unless self.homepage.present?
    body = Http::Fetch.get_one self.homepage
    unless body.present?
      self.homepage = nil
      return
    end
    add_entities! self, Entity.from_html(body)
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
      html = Http::Fetch.get_one(meta[:url])
      body = meta[:content] || Util.text_content(html)
      next unless body.present?
      begin
        description = Util.fix_encoding(MetaInspector.new(meta[:url], document: html).best_description)
      rescue
        next
      end
      post = begin
        posts.where(url: meta[:url]).first_or_create!(title: meta[:title], published_at: meta[:published], description: description)
      rescue ActiveRecord::RecordInvalid
        next
      end
      add_entities! post, Entity.from_html(body)
      meta[:categories].each do |category|
        entity = Entity.from_name(category)
        next unless entity.present?
        PersonEntity.where(entity: entity, person: post).first_or_create!(featured: true)
      end if meta[:categories].present?
    end
  end

  def populate_from_al!
    return unless angelist_user.present? && angelist_user.found?

    self.al_url = angelist_user.angellist_url

    name = angelist_user.name.split(' ')
    self.first_name ||= name.first
    self.last_name ||= name.drop(1).join(' ')

    self.photo = angelist_user.image if angelist_user.image.present?
    self.twitter = angelist_user.twitter if angelist_user.twitter.present?
    self.facebook = angelist_user.facebook if angelist_user.facebook.present?
    self.linkedin = angelist_user.linkedin if angelist_user.linkedin.present?

    self.description = angelist_user.bio if self.description.blank? || (self.description.length < 50 && angelist_user.bio.length > self.description.length)
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
    gender = gender.to_s.remove('mostly_').to_sym if gender.to_s.starts_with?('mostly_')
    self.gender = gender if gender.in?(GENDERS)
  end

  def save_and_fix_duplicates!
    begin
      self.save!
    rescue ActiveRecord::RecordInvalid => e
      raise unless e.record.errors.details.all? { |k,v| v.all? { |e| e[:error].to_sym == :taken } }
      attrs = e.record.errors.details.transform_values { |v| v.first[:value] }
      other = Investor.where(attrs).first
      return unless other.present?
      begin
        other.destroy!
        Investor.from_crunchbase(other.crunchbase_id) if other.crunchbase_id.present? && other.crunchbase_id != self.crunchbase_id
      rescue ActiveRecord::InvalidForeignKey
        other.update! attrs.transform_values { |v| nil }.merge(email: nil, al_id: nil)
        InvestorCrunchbaseJob.perform_later(other.id)
      end
      ignore_invalid { self.save! }
    end
  end

  def self.custom_fuzzy_search(q, existing_ids)
    by_competitor_name = Competitor.where('competitors.name % ?', q).joins(:investors).select('investors.id AS id', 'competitors.name AS name').to_sql
    by_investor_first_name = Investor.where('investors.first_name % ?', q).select('investors.id AS id', 'investors.first_name AS name').to_sql
    by_investor_last_name = Investor.where('investors.last_name % ?', q).select('investors.id AS id', 'investors.last_name AS name').to_sql
    results = "(#{by_competitor_name}) UNION (#{by_investor_first_name}) UNION (#{by_investor_last_name})"
    investors = Investor.joins("INNER JOIN (#{results}) AS results USING (id)")
    investors = investors.where("id NOT IN (#{existing_ids.to_sql})") if existing_ids.to_sql.present?
    investors
      .select('investors.*', Util.sanitize_sql('COALESCE(similarity(results.name, ?), 0) AS rank', q))
      .order('rank DESC', 'investors.featured DESC')
      .limit(10)
  end

  def self.from_crunchbase(cb_id)
    return nil unless cb_id.present?
    ignore_invalid { retry_unique { where(crunchbase_id: cb_id).first_or_create!(&:populate_from_cb_basic!) } }
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

  def demo?
    email == ENV['DEMO_EMAIL']
  end

  def opted_out?
    opted_in == false
  end

  def al_username
    al_url.split('/').last if al_url.present?
  end

  def al_username=(al_username)
    al_url_will_change!
    self.al_url = "https://angel.co/#{al_username}"
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
        :verified,
        :review,
      ],
     methods: [
       :competitor,
       :popular_entities,
       :recent_investments,
       :recent_news,
       :university,
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

  def as_light_json
    as_json(only: [:first_name, :last_name, :photo, :id, :role], methods: [])
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

  def tweeter
    super || (create_tweeter(username: twitter) if twitter.present?)
  end

  def token
    update! token: Util.token unless super.present?
    super
  end

  def tweets(n = 3)
    return [] unless tweeter.present?
    tweeter.tweets.order(tweeted_at: :desc).limit(n)
  end

  def scrape_tweets!
    return unless tweeter.present?
    return if tweeter.private?
    tweeter.latest_tweets.each do |tweet|
      add_entities! self, Entity.from_text(tweet.text)
    end
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

  def set_average_response_time!
    self.average_response_time = Util.average_response_time(emails, :founder_id)
  end

  def founder_overlap(founder)
    founder.entities.where(id: n_popular_entities(50))
  end

  def fetch_review!
    url = URI.escape "http://knapi-prod.us-east-2.elasticbeanstalk.com/api/investors/search?name=#{name}"
    value = HTTP::Fetch.get_one(url)
    return unless value.present?
    response = JSON.parse(value).with_indifferent_access
    return if response[:errors].present?
    return if response[:review].blank? || !response[:review][:published] || response[:review][:overall] < 4
    self.review = { text: response[:review][:comment], id: response[:investorId] }
  end

  def interactions(founder)
    interactions = {
      entities: n_popular_entities(10, Entity.where.not(wiki: nil)).sample(3)
    }
    return interactions unless founder.present?
    email_scope = emails.where(founder: founder).order(created_at: :desc)
    incoming_email = email_scope.where(direction: :incoming).first
    last_opened_email = email_scope.where(direction: :outgoing).joins(:tracking_pixel).where('tracking_pixels.opened_at IS NOT NULL').first
    outgoing_openable = last_opened_email&.tracking_pixel || intro_requests.where(founder: founder).first
    overlap = founder_overlap(founder)
    interactions.merge({
      opened_at: outgoing_openable&.opened_at,
      open_city: outgoing_openable&.open_city,
      travel_status: outgoing_openable&.travel_status,
      last_contact: incoming_email&.created_at,
      overlap: overlap.present? ? overlap : nil,
      paths: founder.count_paths_to(self),
    })
  end

  private

  def check_competitor_domain
    if email.present? && competitor.domain.blank?
      competitor.update! domain: Mail::Address.new(email).domain
    end
  end

  def normalize_location
    self.location = Util.normalize_city(self.location) if self.location.present?
  end

  def import_news_with_attrs(url, body, attrs)
    news = News.where(investor: self, url: url).first_or_initialize(attrs).tap do |news|
      news.body = body
      ignore_invalid { news.save! }
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
        begin
          news.update! company: company
        rescue ActiveRecord::RecordInvalid
          next
        end
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

  def popular_entities
    ids = cached { n_popular_entities.pluck(:id) }
    Entity.find(ids)
  end

  def n_popular_entities(n = 3, scope = Entity.all)
    popular = post_entities(n)
    return popular unless (count = popular.count) < n
    Entity.where(id: entities.order(person_entities_count: :desc).limit(n - count)).or(popular).merge(scope)
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

  def set_first_name
    return unless self.first_name.blank? && self.last_name.blank?
    count = self.class.where(competitor_id: self.competitor_id, first_name: 'Investor').count
    self.first_name = count.present? ? "Investor #{count}" : 'Investor'
  end

  def titleize_role
    return unless self.role.present?
    self.role = self.role.titleize unless self.role.upcase == self.role
  end

  def start_crunchbase_job
    InvestorCrunchbaseJob.perform_later(id)
  end
end
