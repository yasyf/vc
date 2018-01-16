class CreateCompetitorInvestorAggs < ActiveRecord::Migration[5.1]
  def change
    drop_view :competitor_target_counts, materialized: true, revert_to_version: 1
    create_view :competitor_investor_aggs, materialized: true
    add_index :competitor_investor_aggs, :competitor_id, unique: true
    add_index :investors, :featured, order: :desc
    add_index :investors, :verified, order: :desc
  end
end
