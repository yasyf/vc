class CompaniesCompetitor < ApplicationRecord
  belongs_to :company
  belongs_to :competitor
end
