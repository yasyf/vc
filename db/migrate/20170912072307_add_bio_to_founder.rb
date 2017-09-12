class AddBioToFounder < ActiveRecord::Migration[5.1]
  def change
    add_column :founders, :bio, :text
  end
end
