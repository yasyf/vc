class List < ActiveRecord::Base
  has_many :companies

  validates :trello_board_id, presence: true
  validates :trello_id, presence: true, uniqueness:true
  validates :name, presence: true
  validates :pos, presence: true, uniqueness: { scope: :trello_board_id }

  def self.funnel(team)
    where('pos > ?', team.list.ice_box.pos)
    .where('pos < ?', team.lists.scheduled.pos)
    .or(where('id = ?', team.lists.allocated.id))
  end

  def self.sync!
    Team.for_each do |team|
      Trello::Board.find(team.trello_board_id).lists.each do |list_data|
        list = List.where(trello_id: list_data.id).first_or_create do |list|
          list.trello_board_id = team.trello_board_id
        end
        list.assign_attributes %w(name pos).map { |p| [p, list_data.public_send(p)] }.to_h
        list.save! if list.changed?
      end
    end
  end
end
