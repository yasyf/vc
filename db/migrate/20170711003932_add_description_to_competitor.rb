class AddDescriptionToCompetitor < ActiveRecord::Migration[5.1]
  def change
    add_column :competitors, :description, :text
  end
end
