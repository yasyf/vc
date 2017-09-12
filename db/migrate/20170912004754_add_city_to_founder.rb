class AddCityToFounder < ActiveRecord::Migration[5.1]
  def change
    add_column :founders, :city, :string
  end
end
