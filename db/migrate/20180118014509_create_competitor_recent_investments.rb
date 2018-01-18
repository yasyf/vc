class CreateCompetitorRecentInvestments < ActiveRecord::Migration[5.1]
  def change
    create_view :competitor_recent_investments, materialized: true
    add_index :competitor_recent_investments, :competitor_id, unique: true
  end
end
