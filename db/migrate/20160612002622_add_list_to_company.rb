class AddListToCompany < ActiveRecord::Migration[5.0]
  def change
    add_reference :companies, :list, index: true, foreign_key: true
  end
end
