class AddUniquenessIndexToInvestor < ActiveRecord::Migration[5.1]
  def up
    execute '
      DELETE FROM investors i WHERE i.id NOT IN
       (SELECT MIN(id) FROM investors GROUP BY first_name, last_name, competitor_id)
    '
    add_index :investors, [:first_name, :last_name, :competitor_id], unique: true
  end

  def down
    remove_index :investors, [:first_name, :last_name, :competitor_id], unique: true
  end
end
