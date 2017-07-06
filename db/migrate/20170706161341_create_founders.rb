class CreateFounders < ActiveRecord::Migration[5.1]
  def change
    create_table :founders do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email
      t.string :facebook
      t.string :twitter
      t.string :linkedin
      t.string :homepage
      t.string :crunchbase_id

      t.index :crunchbase_id, unique: true
      t.index :twitter, unique: true
      t.index :facebook, unique: true
      t.index :linkedin, unique: true
      t.index :homepage, unique: true
      t.index :email, unique: true

      t.timestamps
    end
  end
end
