class ChangeTeamNullOnCompany < ActiveRecord::Migration[5.1]
  def change
    change_column_null :companies, :team_id, true
  end
end
