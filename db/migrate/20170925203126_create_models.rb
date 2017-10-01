class CreateModels < ActiveRecord::Migration[5.1]
  def change
    create_table :models do |t|
      t.string :name, null: false
      t.integer :version, null: false
      t.bigint :data_generation
      t.bigint :model_generation
      t.datetime :last_trained

      t.timestamps
    end
  end
end
