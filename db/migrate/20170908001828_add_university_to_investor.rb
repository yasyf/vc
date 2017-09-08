class AddUniversityToInvestor < ActiveRecord::Migration[5.1]
  def change
    add_reference :investors, :university, foreign_key: true
  end
end
