class RemovePitchFromCompany < ActiveRecord::Migration[5.1]
  def up
    Company.where('decision_at IS NOT NULL OR pitch_on IS NOT NULL').each do |company|
      Pitch.create!(
          company: company,
          when: company[:pitch_on] || company[:decision_at],
          deadline: company[:deadline],
          decision: company[:decision_at],
          funded: company[:cached_funded],
          snapshot: company[:snapshot_link],
          prevote_doc: company[:prevote_doc_link],
      )
    end
    remove_column :companies, :pitch_on, :date
    remove_column :companies, :decision_at, :datetime
    remove_column :companies, :deadline, :date
    remove_column :companies, :cached_funded, :boolean
    remove_column :companies, :override_quorum, :boolean
    remove_column :companies, :snapshot_link, :string
    remove_column :companies, :prevote_doc_link, :string
  end
  def down
    add_column :companies, :pitch_on, :date
    add_column :companies, :decision_at, :datetime
    add_column :companies, :deadline, :date
    add_column :companies, :cached_funded, :boolean
    add_column :companies, :override_quorum, :boolean
    add_column :companies, :snapshot_link, :string
    add_column :companies, :prevote_doc_link, :string
  end
end
