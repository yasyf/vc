class CreateCompetitorTargetCounts < ActiveRecord::Migration[5.1]
  def change
    create_view :competitor_target_counts, materialized: true
    add_index :competitor_target_counts, :competitor_id, unique: true
  end
end
