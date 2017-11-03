class TargetInvestor < ApplicationRecord
  include Concerns::AttributeSortable
  include Concerns::Eventable

  belongs_to :investor, counter_cache: true
  belongs_to :founder

  INVESTOR_FIELDS = %w(firm_name first_name last_name)

  DUMMY_ATTRS = {
    firm_name: 'Demo Capital',
    first_name: 'Jane',
    last_name: 'Risk',
    role: 'Managing Partner',
    stage: 0,
    industry: [:saas, :ai, :food],
    fund_type: [:seed],
    note: 'met through Jon Doe',
    last_response: 1.day.ago,
  }

  RAW_STAGES = {
    added: 'My Wishlist',
    intro: 'Asked for Intro',
    waiting: 'In Talks',
    respond: 'Need to Respond',
    interested: 'Committed',
    pass: 'Passed',
  }

  STAGES = RAW_STAGES.each_with_index.map { |(k, v), i| ["#{i}_#{k}", v] }.to_h.freeze

  enum stage: STAGES.keys

  validates :investor, uniqueness: { scope: [:founder], allow_nil: true }
  validates :founder, presence: true
  validates :stage, presence: true

  before_save :record_stage_change, :check_investor
  after_commit :fetch_email!, on: :create

  sort :industry
  sort :fund_type

  actions :state_changed, :investor_clicked, :investor_opened, :investor_replied, :intro_requested

  scope :investor_fields_filled, -> { where.not(INVESTOR_FIELDS.map {|f| [f, nil]}.to_h) }

  def self.from_investor!(founder, investor)
    existing = founder.target_investors.where(investor: investor)
    return existing.first if existing.present?
    instance = self.new(investor: investor, founder: founder)
    instance.tap(&:load_from_investor!)
  end

  def self.from_addr(founder, addr)
    target = founder.target_investors.where(email: addr.address).first || founder.target_investors.search(first_name: addr.name, last_name: addr.name).first
    return target if target.present?

    investor = Investor.from_addr(addr)
    founder.target_investors.where(investor: investor).first if investor.present?
  end

  def self.from_addr!(founder, addr)
    target = from_addr(founder, addr)
    return target if target.present?

    investor = Investor.from_addr(addr)
    target = from_investor!(founder, investor) if investor.present?
    return target if target.present?

    first, last = Util.split_name(addr.name)
    create! first_name: first, last_name: last, email: addr.address, note: 'imported from email'
  end

  def load_from_investor!
    return unless investor.present?
    %w(first_name last_name role industry fund_type).each do |attr|
      self[attr] = investor[attr]
    end
    self.email = investor.email if founder.drf?
    self.firm_name = investor.competitor.name
    save!
  end

  def find_investor!
    return unless investor_fields_present?
    check_investor && (save! if changed?)
    return unless self.investor.blank?
    investor = Investor.from_name("#{first_name} #{last_name}")
    return unless investor.present? && investor.competitor.present?
    distance = Levenshtein.distance investor.competitor.name, firm_name
    if distance <= 3
      self.investor ||= investor
      save! if changed?
    end
  end

  def can_intro?
    email.blank? &&
      intro_request.blank? &&
      investor&.email.present? &&
      investor&.opted_in != false &&
      stage == STAGES.first.first
  end

  def intro_request
    return nil unless investor.present?
    founder.intro_requests.where(investor: investor).first
  end

  def overlap
    return [] unless investor.present?
    investor.founder_overlap(founder)
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def title
    role.present? ? "#{role}, #{firm_name}" : firm_name
  end

  def as_json(options = {})
    super options.reverse_merge(
      only: [:id, :stage, :first_name, :last_name, :last_response, :note, :priority, :role, :firm_name],
      methods: [:can_intro?, :intro_request, :overlap, :full_name, :title],
      include: { investor: { only: [:id, :first_name, :last_name, :photo] } },
    )
  end

  private

  def investor_fields_present?
    INVESTOR_FIELDS.all? { |f| send(f).present? }
  end

  def investor_fields_changed?
    INVESTOR_FIELDS.any? { |f| send("#{f}_changed?") }
  end

  def fetch_email!
    InvestorEmailJob.perform_later(investor.id) if investor.present? && investor.email.blank?
  end

  def check_investor
    return unless investor_fields_present?
    return unless investor_fields_changed?
    investors = Investor
      .includes(:competitor)
      .references(:competitors)
      .search(first_name: first_name, last_name: last_name, competitors: { name: firm_name })
      .where.not(id: founder.existing_target_investor_ids - [self.investor_id])
      .limit(1)
    self.investor = investors.first
  end

  def record_stage_change
    return if stage == stage_was
    state_changed! stage_was, stage
    self.last_response = DateTime.now if stage.to_s == '3_respond' || stage_was.to_s == '2_waiting'
  end
end
