class AddFundingSizeToCompetitor < ActiveRecord::Migration[5.1]
  def change
    add_column :competitors, :funding_size, :integer
  end
end
