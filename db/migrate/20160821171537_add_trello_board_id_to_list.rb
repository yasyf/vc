class AddTrelloBoardIdToList < ActiveRecord::Migration[5.0]
  def up
    add_column :lists, :trello_board_id, :string
    change_column_null :lists, :trello_board_id, false, Team.default.trello_board_id
  end

  def down
    remove_column :lists, :trello_board_id
  end
end
