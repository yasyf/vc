class AddCityToCompetitor < ActiveRecord::Migration[5.1]
  def change
    add_column :competitors, :city, :string
  end
end
