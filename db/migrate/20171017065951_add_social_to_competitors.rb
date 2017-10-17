class AddSocialToCompetitors < ActiveRecord::Migration[5.1]
  def change
    add_column :competitors, :twitter, :string
    add_column :competitors, :facebook, :string
  end
end
