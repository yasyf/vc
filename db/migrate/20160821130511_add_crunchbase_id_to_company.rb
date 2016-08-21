class AddCrunchbaseIdToCompany < ActiveRecord::Migration[5.0]
  def up
    add_column :companies, :crunchbase_id, :string, unique: true
    Company.reset_column_information
    Company.all.each do |company|
      company.send(:set_crunchbase_id)
      company.save!
    end
  end

  def down
    remove_column :companies, :crunchbase_id
  end
end
