class AddTeamToCompany < ActiveRecord::Migration[5.0]
  def up
    add_reference :companies, :team, foreign_key: true
    change_column_null :companies, :team_id, false, Team.default.id
  end

  def down
    remove_reference :companies, :team
  end
end
