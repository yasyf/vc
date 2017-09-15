class AddAlUrlToInvestor < ActiveRecord::Migration[5.1]
  def change
    add_column :investors, :al_url, :string
  end
end
