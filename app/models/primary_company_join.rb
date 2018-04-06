class PrimaryCompanyJoin < ApplicationRecord
  belongs_to :founder
  belongs_to :company

  def readonly?
    true
  end
end
