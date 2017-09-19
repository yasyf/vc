class AddQuorumToPitch < ActiveRecord::Migration[5.1]
  def change
    add_column :pitches, :quorum, :integer
    Pitch.find_each do |pitch|
      pitch.send(:set_quorum!)
      pitch.save!
    end
    change_column_null :pitches, :quorum, false
  end
end
