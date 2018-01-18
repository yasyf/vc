class CreateCompetitorPartners < ActiveRecord::Migration[5.1]
  def change
    create_view :competitor_partners, materialized: true
    add_index :competitor_partners, :competitor_id, unique: true
  end
end
