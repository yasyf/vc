class AddDomainToCompetitors < ActiveRecord::Migration[5.1]
  def change
    add_column :competitors, :domain, :string
  end
end
