class AddPublishedAtToNews < ActiveRecord::Migration[5.1]
  def change
    add_column :news, :published_at, :datetime
  end
end
