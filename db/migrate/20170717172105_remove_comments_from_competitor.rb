class RemoveCommentsFromCompetitor < ActiveRecord::Migration[5.1]
  def change
    remove_column :competitors, :comments, :text
  end
end
