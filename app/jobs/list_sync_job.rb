class ListSyncJob < ApplicationJob
  queue_as :default

  def perform(team)
    team.trello_board_ids.each do |trello_board_id|
      Trello::Board.find(trello_board_id).lists.each do |list_data|
        list = List.where(trello_id: list_data.id).first_or_create do |list|
          list.trello_board_id = trello_board_id
        end
        list.assign_attributes %w(name pos).map { |p| [p, list_data.public_send(p)] }.to_h
        list.save! if list.changed?
      end
    end
  end
end
