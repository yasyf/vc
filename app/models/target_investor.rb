class TargetInvestor < ApplicationRecord
  include Concerns::AttributeSortable

  belongs_to :investor, counter_cache: true
  belongs_to :founder

  DUMMY_ATTRS = {
    firm_name: 'Demo Capital',
    first_name: 'Jane',
    last_name: 'Risk',
    role: 'Managing Partner',
    stage: 0,
    industry: [:saas, :ai, :food],
    funding_size: 1,
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
  enum funding_size: Competitor::FUNDING_SIZES.keys

  validates :investor, uniqueness: { scope: [:founder], allow_nil: true }
  validates :founder, presence: true
  validates :stage, presence: true

  before_save :check_stage_change, :check_investor

  sort :industry

  private

  def check_investor
    return unless %w(firm_name first_name last_name).all? { |a| send(a).present? }
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
