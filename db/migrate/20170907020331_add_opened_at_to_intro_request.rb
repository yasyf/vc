class AddOpenedAtToIntroRequest < ActiveRecord::Migration[5.1]
  def change
    add_column :intro_requests, :opened_at, :datetime
  end
end
