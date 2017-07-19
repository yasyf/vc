class RenameCompanyToPitchOnVote < ActiveRecord::Migration[5.1]
  def up
    add_reference :votes, :pitch, foreign_key: true, index: true
    Pitch.find_each do |pitch|
      Vote.where(company_id: pitch.company_id).update_all(pitch_id: pitch.id)
    end
    remove_reference :votes, :company, index: true
  end

  def down
    add_reference :votes, :company, index: true
    Pitch.find_each do |pitch|
      Vote.where(pitch_id: pitch.id).update(company_id: pitch.company_id)
    end
    remove_reference :votes, :pitch, foreign_key: true, index: true
  end
end
