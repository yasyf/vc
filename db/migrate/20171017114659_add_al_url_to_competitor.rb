class AddAlUrlToCompetitor < ActiveRecord::Migration[5.1]
  def change
    add_column :competitors, :al_url, :string
  end
end
