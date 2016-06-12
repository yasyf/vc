class AddListToCompany < ActiveRecord::Migration
  def change
    add_reference :companies, :list, index: true, foreign_key: true
  end
end
