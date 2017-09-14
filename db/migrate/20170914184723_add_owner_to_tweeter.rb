class AddOwnerToTweeter < ActiveRecord::Migration[5.1]
  def change
    add_reference :tweeters, :owner, polymorphic: true, index: true
    reversible do |dir|
      dir.up { Tweeter.connection.execute "UPDATE tweeters SET owner_type = 'Company', owner_id = company_id" }
    end
    change_column_null :tweeters, :owner_type, false
    change_column_null :tweeters, :owner_id, false
    remove_column :tweeters, :company_id
  end
end
