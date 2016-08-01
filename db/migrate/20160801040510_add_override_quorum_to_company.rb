class AddOverrideQuorumToCompany < ActiveRecord::Migration[5.0]
  def change
    add_column :companies, :override_quorum, :bool, null: false, default: false
  end
end
