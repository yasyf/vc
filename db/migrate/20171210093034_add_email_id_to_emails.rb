class AddEmailIdToEmails < ActiveRecord::Migration[5.1]
  def change
    add_column :emails, :email_id, :string
    add_index :emails, :email_id, unique: true
  end
end
