class Founder < ApplicationRecord
  include Concerns::Cacheable
  include Concerns::TimeZonable
  include Concerns::Eventable

  SOCIAL_KEYS = %w(linkedin twitter homepage facebook)

  has_and_belongs_to_many :companies, -> { distinct }
  has_many :notes
  has_many :import_tasks
  has_many :emails, dependent: :destroy
  has_many :intro_requests, dependent: :destroy
  has_many :target_investors, dependent: :destroy
  has_many :person_entities, as: :person
  has_many :entities, through: :person_entities

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, uniqueness: { allow_nil: true }

  after_commit :start_augment_job, on: :create
  after_commit :start_enhance_job, on: :update

  action :investor_clicked

  devise

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
    from_email(auth.info.email, auth.info.first_name, auth.info.last_name) if auth.present?
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
    # TODO: store competitors
    attrs = {
      founders: [self],
      name: data[:name],
      description: data[:description],
      industry: Util.split_slice(data[:industry], Competitor::INDUSTRIES).keys
    }
    if data[:domain]
      Company.where(domain: Util.parse_domain(data[:domain])).first_or_initialize.tap do |c|
        c.update! attrs
      end
    else
      Company.create!(attrs)
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
      counts: target_investors.group_by(&:stage).transform_values(&:count),
      total: target_investors.size,
      recents: target_investors.order(created_at: :desc).limit(3).pluck(:firm_name),
    }
  end

  def as_json(options = {})
    super options.reverse_merge(only: [:id, :first_name, :last_name], methods: [:drf?, :primary_company, :utc_offset, :conversations, :events])
  end

  def existing_target_investor_ids
    target_investors.where.not(investor_id: nil).select('investor_id')
  end

  def ensure_target_investors!
    target_investors.create! TargetInvestor::DUMMY_ATTRS if target_investors.count == 0
  end

  def events
    Event
      .where(subject_type: TargetInvestor.name)
      .where(action: %w(investor_opened investor_clicked intro_requested investor_replied))
      .joins('INNER JOIN target_investors ON events.subject_id = target_investors.id')
      .where('target_investors.founder_id = ?', id)
      .order(created_at: :desc)
      .select('events.action, events.id, events.arg1, events.arg2, target_investors.first_name, target_investors.last_name')
      .limit(3)
  end

  def recommended_investors(limit: 5, offset: 0)
    query = <<-SQL
      SELECT DISTINCT ON (i.featured, i_ind.cnt, count(companies.id), i.target_investors_count, i.competitor_id)
        i.*, i_ind.cnt as ind_cnt, i_ind.industry_highlight, count(companies.id) as cnt
      FROM
        investors i,
        LATERAL (
           SELECT
            count(*) AS cnt,
            array_agg(i_ind_t) AS industry_highlight
           FROM   unnest(i.industry) i_ind_t
           WHERE  i_ind_t = ANY('{#{primary_company.industry.join(',')}}')
        ) i_ind
      LEFT OUTER JOIN investments on (investments.id = investments.investor_id)
      LEFT OUTER JOIN companies on (investments.company_id = companies.id)
      WHERE i_ind.cnt > 0
      GROUP BY i.id, i_ind.cnt, i_ind.industry_highlight
      ORDER BY i.featured DESC, i_ind.cnt DESC, count(companies.id) DESC, i.target_investors_count DESC, i.competitor_id DESC
      LIMIT #{limit}
      OFFSET #{offset};
    SQL
    Investor.find_by_sql query
  end

  private

  def start_augment_job
    FounderEnhanceJob.perform_later(self.id, augment: email.present?)
  end

  def start_enhance_job
    FounderEnhanceJob.perform_later(self.id, augment: false) if ip_address_changed?
  end
end
