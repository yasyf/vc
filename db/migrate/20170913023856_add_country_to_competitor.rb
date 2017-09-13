class AddCountryToCompetitor < ActiveRecord::Migration[5.1]
  def change
    add_column :competitors, :country, :string
  end
end
