class List < ActiveRecord::Base
  validates :trello_id, presence: true, uniqueness:true
  validates :name, presence: true
  validates :pos, presence: true, uniqueness: true

  def self.sync!
    Trello::Board.find(ENV['TRELLO_BOARD']).lists.each do |list_data|
      list = List.where(trello_id: list_data.id).first_or_create
      list.assign_attributes %w(name pos).map { |p| [p, list_data.public_send(p)] }.to_h
      list.save! if list.changed?
    end
  end
end
