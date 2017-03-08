class List < ActiveRecord::Base
  has_many :companies

  validates :trello_board_id, presence: true
  validates :trello_id, presence: true, uniqueness:true
  validates :name, presence: true
  validates :pos, presence: true, uniqueness: { scope: :trello_board_id }

  def self.funnel(team)
    where(trello_board_id: team.trello_board_ids)
    .where('pos >= ? AND pos < ?', team.lists.allocated.pos, team.lists.scheduled.pos)
    .where('pos != ?', team.lists.ice_box.pos)
  end

  def self.sync!
    Team.for_each do |team|
      ListSyncJob.perform_later(team)
    end
  end
end
