class AddAlIdToCompetitor < ActiveRecord::Migration[5.1]
  def change
    add_column :competitors, :al_id, :integer
  end
end
