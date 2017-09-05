class AddAlIdToCompany < ActiveRecord::Migration[5.1]
  def change
    add_column :companies, :al_id, :integer
  end
end
