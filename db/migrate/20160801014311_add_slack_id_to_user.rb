class AddSlackIdToUser < ActiveRecord::Migration[5.0]
  def up
    add_column :users, :slack_id, :string, unique: true, index: true
    User.reset_column_information
    User.find_each do |user|
      user.send(:set_slack_id)
      user.save!
    end
  end

  def down
    remove_column :users, :slack_id
  end
end
