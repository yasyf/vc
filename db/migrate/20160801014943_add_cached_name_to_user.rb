class AddCachedNameToUser < ActiveRecord::Migration[5.0]
  def up
    add_column :users, :cached_name, :string, unique: true, index: true
    User.reset_column_information
    User.find_each do |user|
      user.send(:set_cached_name)
      user.save!
    end
    change_column_null :users, :cached_name, false
  end

  def down
    remove_column :users, :cached_name
  end
end
