class CreateJoinTableCompaniesFounders < ActiveRecord::Migration[5.1]
  def change
    create_join_table :companies, :founders do |t|
      t.index [:company_id, :founder_id], unique: true
      t.index [:founder_id, :company_id], unique: true
    end
  end
end
