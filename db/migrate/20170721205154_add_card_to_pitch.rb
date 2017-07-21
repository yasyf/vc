class AddCardToPitch < ActiveRecord::Migration[5.1]
  def change
    add_reference :pitches, :card, foreign_key: true
    reversible do |dir|
      dir.up do
        Pitch.find_each do |pitch|
          pitch.update! card: pitch.company.card
        end
      end
    end
  end
end
