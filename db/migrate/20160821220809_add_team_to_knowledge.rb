class AddTeamToKnowledge < ActiveRecord::Migration[5.0]
  def up
    add_reference :knowledges, :team, foreign_key: true
    change_column_null :knowledges, :team_id, false, Team.default.id
  end

  def down
    remove_reference :knowledges, :team
  end
end
