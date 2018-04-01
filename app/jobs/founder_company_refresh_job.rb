class FounderEnhanceJob < ApplicationJob
  queue_as :long

  def perform(founder_id, augment: false)
    Founder.active(1.year.ago).find_each do |founder|
      founder.companies.pluck(:id).each do |company_id|
        CompanyRelationshipsJob.perform_later(company_id)
      end
    end
  end
end
