class CompanyExtraAttributesJob < ApplicationJob
  queue_as :low

  def perform(company_id)
    company = Company.find(company_id)
    company.set_extra_attributes!
    company.save!
  end
end
