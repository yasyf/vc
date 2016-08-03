class AddSnapshotLinkToCompany < ActiveRecord::Migration[5.0]
  def up
    add_column :companies, :snapshot_link, :string, unique: true
    Company.reset_column_information
    Company.all.each do |company|
      company.send(:set_snapshot_link)
      company.save!
    end
  end

  def down
    remove_column :companies, :snapshot_link
  end
end
