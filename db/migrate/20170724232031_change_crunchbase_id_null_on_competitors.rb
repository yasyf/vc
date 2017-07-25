class ChangeCrunchbaseIdNullOnCompetitors < ActiveRecord::Migration[5.1]
  def change
    change_column_null :competitors, :crunchbase_id, true
  end
end
