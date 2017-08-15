class AddTimestampsToCompaniesCompetitors < ActiveRecord::Migration[5.1]
  def change
    change_table :companies_competitors do |t|
      t.datetime :funded_at, default: Time.now, null: false
      t.primary_key :id, first: true
    end
  end
end
