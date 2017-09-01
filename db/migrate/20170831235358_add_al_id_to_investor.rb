class AddAlIdToInvestor < ActiveRecord::Migration[5.1]
  def change
    add_column :investors, :al_id, :integer
  end
end
