class CreateJoinTableCompaniesCompetitors < ActiveRecord::Migration[5.0]
  def change
    create_join_table :companies, :competitors do |t|
      t.index [:company_id, :competitor_id], unique: true
      t.index [:competitor_id, :company_id], unique: true
    end
  end
end
