class ChangeAcceptedOnIntroRequest < ActiveRecord::Migration[5.1]
  def change
    change_column_null :intro_requests, :accepted, true
    change_column_default :intro_requests, :accepted, nil
  end
end
