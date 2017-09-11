class AddIndexToEmails < ActiveRecord::Migration[5.1]
  def change
    add_index :emails, [:investor_id, :founder_id, :direction, :created_at], name: 'index_emails_on_investor_founder_dir_ca', using: 'gin'
  end
end