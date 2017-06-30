class RemovePitchFromCompany < ActiveRecord::Migration[5.1]
  def up
    Company.where.not(pitch_on: nil).each do |company|
      Pitch.create! company: company, when: company[:pitch_on], decision: company[:decision_at], cached_funded: company[:cached_funded]
    end
    remove_column :companies, :pitch_on, :date
    remove_column :companies, :decision_at, :datetime
    remove_column :companies, :cached_funded, :boolean
  end
  def down
    add_column :companies, :pitch_on, :date
    add_column :companies, :decision_at, :datetime
    add_column :companies, :cached_funded, :boolean
  end
end
