class AddTrelloIdToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :trello_id, :string, unique: true, index: true
  end
end
