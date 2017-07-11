class AddIndustryToCompetitor < ActiveRecord::Migration[5.1]
  def change
    add_column :competitors, :industry, :string
  end
end
