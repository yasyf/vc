class AddPitchDeckToIntroRequest < ActiveRecord::Migration[5.1]
  def change
    add_column :intro_requests, :pitch_deck, :string
  end
end
