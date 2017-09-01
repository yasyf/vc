class TargetInvestor < ApplicationRecord
  include Concerns::AttributeSortable

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

  STAGES = {
    added: 'Need To Reach Out',
    intro: 'Waiting For Intro',
    waiting: 'Waiting For Response',
    respond: 'Need To Respond',
    interested: 'Interested',
    pass: 'Not Interested',
  }.each_with_index.map { |(k, v), i| ["#{i}_#{k}", v] }.to_h.freeze

  enum stage: STAGES.keys

  validates :investor, uniqueness: { scope: [:founder], allow_nil: true }
  validates :founder, presence: true
  validates :stage, presence: true

  before_save :check_stage_change, :check_investor

  sort :industry
  sort :fund_type

  scope :investor_fields_filled, -> { where.not(INVESTOR_FIELDS.map {|f| [f, nil]}.to_h) }

  def self.from_investor!(founder, investor)
    instance = self.new(investor: investor, founder: founder)
    instance.tap(&:load_from_investor!)
  end

  def load_from_investor!
    return unless investor.present?
    %w(first_name last_name role industry fund_type email).each do |attr|
      self[attr] = investor[attr]
    end
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

  private

  def investor_fields_present?
    INVESTOR_FIELDS.all? { |f| send(f).present? }
  end

  def check_investor
    return unless investor_fields_present?
    investors = Investor
      .includes(:competitor)
      .references(:competitors)
      .search(first_name: first_name, last_name: last_name, competitors: { name: firm_name })
      .where.not(id: founder.existing_target_investor_ids)
      .limit(1)
    self.investor = investors.first
  end

  def check_stage_change
    return if stage == stage_was
    LoggedEvent.log! :target_stage_changed, self,
                     notify: 0, data: { from: stage_was, to: stage }
    self.last_response = DateTime.now if stage.to_sym == :respond
  end
end
