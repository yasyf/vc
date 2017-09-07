class AddReasonToIntroRequest < ActiveRecord::Migration[5.1]
  def change
    add_column :intro_requests, :reason, :string
  end
end
