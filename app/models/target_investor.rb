class TargetInvestor < ApplicationRecord
  belongs_to :investor
  belongs_to :founder

  STAGES = {
    added: 'Need To Reach Out',
    intro: 'Waiting For Intro',
    waiting: 'Waiting For Response',
    respond: 'Need To Respond',
    interested: 'Interesed',
    pass: 'Not Interested',
  }.freeze

  enum stage: STAGES.keys
  enum funding_size: Competitor::FUNDING_SIZES.keys

  validates :investor, presence: true, uniqueness: { scope: [:founder] }
  validates :founder, presence: true
  validates :stage, presence: true
  validates :tier, presence: true, numericality: { greater_than: 0, only_integer: true }

  def change_stage!(new_stage)
    return if stage == new_stage
    LoggedEvent.log! :target_stage_changed, self,
                     notify: 0, data: { from: stage, to: new_stage }
    self.stage = new_stage
    self.last_response = DateTime.now if new_stage == :respond
    save!
  end

  def as_json(options = {})
    super options.reverse_merge(only: [:industry, :funding_size, :stage, :tier, :id], methods: [:investor])
  end
end
