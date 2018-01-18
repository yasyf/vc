class CreateCompetitorCoinvestors < ActiveRecord::Migration[5.1]
  def change
    create_view :competitor_coinvestors, materialized: true
    add_index :competitor_coinvestors, :competitor_id, unique: true
  end
end
