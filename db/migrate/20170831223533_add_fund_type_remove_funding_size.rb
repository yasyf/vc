class AddFundTypeRemoveFundingSize < ActiveRecord::Migration[5.1]
  def change
    remove_column :competitors, :funding_size, :integer
    remove_column :investors, :funding_size, :integer
    remove_column :target_investors, :funding_size, :integer

    add_column :competitors, :fund_type, :string, array: true
    add_column :investors, :fund_type, :string, array: true
    add_column :target_investors, :fund_type, :string, array: true

    add_index :competitors, :fund_type, using: 'gin'
    add_index :investors, :fund_type, using: 'gin'
    add_index :target_investors, :fund_type, using: 'gin'
  end
end
