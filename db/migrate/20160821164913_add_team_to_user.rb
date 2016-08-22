class AddTeamToUser < ActiveRecord::Migration[5.0]
  def up
    add_reference :users, :team, foreign_key: true
  end

  def down
    remove_reference :users, :team
  end
end
