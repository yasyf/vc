class RemoveCityFromCompetitors < ActiveRecord::Migration[5.1]
  def change
    remove_column :competitors, :city, :string
  end
end
