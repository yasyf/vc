class AddIntroRequestToEmail < ActiveRecord::Migration[5.1]
  def change
    add_reference :emails, :intro_request, foreign_key: true
  end
end
