class CompanyExtraAttributesJob < ApplicationJob
  queue_as :low

  def perform(company_id)
    company = Company.find(company_id)
    company.set_extra_attributes!
    begin
      ignore_invalid { company.save! } if company.changed?
    rescue *unique_errors
      attrs = company.errors.details.map { |k,_| [k, company.send(k)] }.to_h
      DuplicateCompanyJob.perform_later(company.id, attrs)
      return
    end
  end
end
