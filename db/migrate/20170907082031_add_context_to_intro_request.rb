class AddContextToIntroRequest < ActiveRecord::Migration[5.1]
  def change
    add_column :intro_requests, :context, :text
  end
end
