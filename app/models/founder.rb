class Founder < ApplicationRecord
  include Concerns::Cacheable
  include Concerns::TimeZonable
  include Concerns::Eventable
  include Concerns::Locationable

  SOCIAL_KEYS = %w(linkedin twitter homepage facebook)

  has_and_belongs_to_many :companies, -> { distinct }
  has_many :notes
  has_many :import_tasks, dependent: :destroy
  has_many :emails, dependent: :destroy
  has_many :intro_requests, -> { where(pending: false) }, dependent: :destroy
  has_many :target_investors, dependent: :destroy
  has_many :person_entities, as: :person, dependent: :destroy
  has_many :entities, through: :person_entities

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, uniqueness: { allow_nil: true }
  validates :facebook, uniqueness: { allow_nil: true }
  validates :twitter, uniqueness: { allow_nil: true }
  validates :linkedin, uniqueness: { allow_nil: true }
  validates :homepage, uniqueness: { allow_nil: true }

  before_validation :normalize_city
  after_commit :start_augment_job, on: :create
  after_commit :start_enhance_job, on: :update
  after_touch :start_touch_job

  action :competitor_clicked, :investor_clicked, :investor_targeted
  locationable_with :city

  devise

  def self.active
    where('logged_in_at > ?', 1.month.ago).joins(:companies).where('companies.primary = ?', true)
  end

  def self.find_or_create_from_social!(first_name, last_name, social, context: nil)
    name_hash = {first_name: first_name, last_name: last_name}
    social = social.select { |k,v| v.present? }
    attrs = social.merge(name_hash)

    if social.blank?
      return (context.present? && context.founders.where(name_hash).empty?) ? create!(name_hash) : nil
    end

    found = social.inject(none) { |scope, (attr, val)| scope.or(where(attr => val)) }.first
    found.present? ? found.tap { |f| f.update!(attrs) } : create!(attrs)
  end

  def self.from_omniauth(auth)
    return nil unless auth.present?
    from_email(auth.info.email, auth.info.first_name, auth.info.last_name).tap do |founder|
      founder.photo ||= auth.info.image
      founder.assign_attributes access_token: auth.credentials.token, refresh_token: auth.credentials.refresh_token
      founder.save!
    end
  end

  def self.from_email(email, first_name = nil, last_name = nil)
    where(email: email).first_or_create! do |f|
      f.first_name = first_name
      f.last_name = last_name
    end
  end

  def self.export_rating_data(filename)
    added = Set.new
    CSV.open(filename, 'wb') do |csv|
      csv << %w(founder_id investor_id rating)

      all
        .joins(companies: :investments)
        .includes(companies: :investments)
        .where.not('investments.investor_id': nil)
        .in_batches do |relation|
          relation
            .joins('LEFT OUTER JOIN news ON (investments.investor_id = news.investor_id AND companies.id = news.company_id)')
            .group('founders.id', 'investments.investor_id')
            .pluck('founders.id', 'investments.investor_id', '(1 + count(news)) * greatest(1, avg(coalesce(news.sentiment_score, 0) * coalesce(news.sentiment_magnitude, 0) * 10))')
            .each do |(founder_id, investor_id, ranking)|
              csv << [founder_id, investor_id, ranking]
              added.add([founder_id, investor_id])
          end
      end

      scope = all.joins(:target_investors).includes(:target_investors).where.not('target_investors.investor_id': nil)
      scope = added.inject(scope) { |s, ids| s.where.not('founders.id = ? AND target_investors.investor_id = ?', *ids) }
      scope.in_batches do |relation|
        relation
          .joins("LEFT OUTER JOIN events ON (founders.id = events.subject_id AND target_investors.investor_id = events.arg1::bigint AND subject_type = 'Founder' AND action = 'investor_clicked')")
          .group('founders.id', 'target_investors.investor_id')
          .pluck('founders.id', 'target_investors.investor_id', '1 + count(events) * 0.5')
          .each do |(founder_id, investor_id, ranking)|
            csv << [founder_id, investor_id, ranking]
            added.add([founder_id, investor_id])
        end
      end

      scope = all.joins(:intro_requests).includes(:intro_requests)
      scope = added.inject(scope) { |s, ids| s.where.not('founders.id = ? AND intro_requests.investor_id = ?', *ids) }
      scope.in_batches do |relation|
        relation
          .joins('LEFT OUTER JOIN emails ON (founders.id = emails.founder_id AND intro_requests.investor_id = emails.investor_id')
          .group('founders.id', 'intro_request.investor_id')
          .pluck('founders.id', 'intro_request.investor_id', '1 + count(emails) * greatest(1, avg(coalesce(emails.sentiment_score, 0) * coalesce(emails.sentiment_magnitude, 0) * 10))')
          .each do |(founder_id, investor_id, ranking)|
            csv << [founder_id, investor_id, ranking]
            added.add([founder_id, investor_id])
          end
      end
    end
    added.count
  end

  def create_target!(investor)
    TargetInvestor.from_investor! self, investor
  end

  def create_company!(data)
    attrs = {
      founders: [self],
      name: data[:name],
      description: data[:description],
      location: data[:location].split(',').first,
      primary: true,
    }
    attrs[:industry] = Util.split_slice(data[:industry], Competitor::INDUSTRIES).keys if data[:industry].present?
    if data[:domain].present?
      Company.where(domain: Util.parse_domain(data[:domain])).first_or_initialize.tap do |c|
        c.update! attrs
      end
    else
      Company.create!(attrs)
    end.tap do |company|
      company.competitions = Company.where(id: data[:companies].split(', ')) if data[:companies].present?
    end
  end

  def name
    "#{first_name} #{last_name}"
  end

  def domain
    return nil unless email.present?
    email.split('@').last
  end

  def admin?
    domain == ENV['DOMAIN']
  end

  def drf?
    cached { companies.any?(&:funded?) } || admin? || Rails.env.development?
  end

  def primary_company
    @primary_company ||= companies.where(primary: true).last || companies.last
  end

  def conversations
    {
      total: target_investors.size,
      recents: grouped_conversations,
    }
  end

  def linkedin=(linkedin)
    super linkedin.split('/')[4] || linkedin
  end

  def twitter=(twitter)
    twitter = twitter&.split('/')&.last || twitter
    super twitter&.first == '@' ? twitter[1..-1] : twitter
  end

  def as_json(options = {})
    super(options.reverse_merge(
      only: [:id, :first_name, :last_name, :city, :linkedin, :twitter, :homepage],
      methods: [:drf?, :primary_company, :utc_offset, :conversations, :events_with_meta, :stats]
    )).reverse_merge(
      target_investors: target_investors.includes(:intro_requests).order(updated_at: :desc).as_json(include: [], methods: [:intro_requests])
    )
  end

  def cached_json
    Rails.env.development? ? as_json : cache_for_a_hour { as_json }
  end

  def existing_target_investor_ids
    target_investors.where.not(investor_id: nil).select('investor_id')
  end

  def ensure_target_investors!
    target_investors.create! TargetInvestor::DUMMY_ATTRS if target_investors.count == 0
  end

  def stats(scope = Email.all)
    {
      emails: emails.merge(scope).count,
      investors: emails.merge(scope).count('DISTINCT investor_id'),
      response_time: response_time,
    }
  end

  def events(scope = Event.all)
    Event
      .where(subject_type: TargetInvestor.name)
      .where(action: %w(investor_opened investor_clicked intro_requested investor_replied))
      .order(created_at: :desc)
      .merge(scope)
  end

  def events_with_meta
    events(Event.limit(3))
      .joins('INNER JOIN target_investors ON events.subject_id = target_investors.id')
      .where('target_investors.founder_id = ?', id)
      .select('events.action, events.id, events.arg1, events.arg2, target_investors.first_name, target_investors.last_name, target_investors.firm_name')
  end

  private

  def normalize_city
    self.city = Util.normalize_city(self.city) if self.city.present?
  end

  def set_response_time!
    update! response_time: Util.average_response_time(emails, :investor_id)
  end

  def grouped_conversations
    target_investors
      .order(created_at: :desc)
      .pluck(:stage, :firm_name)
      .group_by { |v| TargetInvestor::CATEGORIES[v.first] }
      .transform_values { |v| v.map(&:last) }
  end

  def start_touch_job
    FounderRefreshJob.perform_later(self.id)
  end

  def start_augment_job
    FounderEnhanceJob.perform_later(self.id, augment: email.present?)
  end

  def start_enhance_job
    return unless logged_in_at_changed?
    IntroRequest.where(founder: self).update_all preview_html: nil
    FounderEnhanceJob.perform_later(self.id, augment: false) if ip_address_changed?
  end
end
