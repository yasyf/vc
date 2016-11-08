class AddPrevoteDocLinkToCompany < ActiveRecord::Migration[5.0]
  def change
    add_column :companies, :prevote_doc_link, :string
  end
end
