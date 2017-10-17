class AddHqToCompetitor < ActiveRecord::Migration[5.1]
  def change
    add_column :competitors, :hq, :string
  end
end
