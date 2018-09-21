class AddStageToCompanies < ActiveRecord::Migration[5.2]
  def change
    add_column :companies, :stage, :integer, default: 0
  end
end
