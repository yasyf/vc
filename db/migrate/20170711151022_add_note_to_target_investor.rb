class AddNoteToTargetInvestor < ActiveRecord::Migration[5.1]
  def change
    add_column :target_investors, :note, :text
  end
end
