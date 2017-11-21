class AddPreviewHtmlToIntroRequest < ActiveRecord::Migration[5.1]
  def change
    add_column :intro_requests, :preview_html, :text
    add_column :intro_requests, :pending, :boolean, null: false, default: true
  end
end
