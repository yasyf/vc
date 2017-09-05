class AddLocationToCompetitor < ActiveRecord::Migration[5.1]
  def change
    add_column :competitors, :location, :string, array: true
    add_index :competitors, :location, using: 'gin'
  end
end
