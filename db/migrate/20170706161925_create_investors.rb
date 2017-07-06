class CreateInvestors < ActiveRecord::Migration[5.1]
  def change
    create_table :investors do |t|
      t.string :name
      t.string :email
      t.belongs_to :competitor, foreign_key: true

      t.timestamps
    end
  end
end
