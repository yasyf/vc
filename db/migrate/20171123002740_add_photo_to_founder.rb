class AddPhotoToFounder < ActiveRecord::Migration[5.1]
  def change
    add_column :founders, :photo, :string
  end
end
