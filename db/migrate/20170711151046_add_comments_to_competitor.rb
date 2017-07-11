class AddCommentsToCompetitor < ActiveRecord::Migration[5.1]
  def change
    add_column :competitors, :comments, :text
  end
end
