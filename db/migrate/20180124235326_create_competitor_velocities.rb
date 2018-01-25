class CreateCompetitorVelocities < ActiveRecord::Migration[5.1]
  def change
    create_view :competitor_velocities, materialized: true
    add_index :competitor_velocities, :competitor_id, unique: true
  end
end
