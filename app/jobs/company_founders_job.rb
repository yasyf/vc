class CompanyFoundersJob < ApplicationJob
  queue_as :default

  TIMEOUT = 5
  SOCIAL_KEYS = %w(homepage twitter linkedin facebook)

  def perform(company_id)
    company = Company.find(company_id)
    company.crunchbase_org(TIMEOUT).founders.each do |founder|
      person = Http::Crunchbase::Person.new(founder['properties']['permalink'], TIMEOUT)
      social = SOCIAL_KEYS.map { |k| [k, person.public_send(k)] }.to_h
      founder = Founder.find_or_create_from_social!(person.first_name, person.last_name, social, context: company)
      begin
        founder.tap { |f| f.companies << company }.save! if founder.present?
      rescue ActiveRecord::RecordNotUnique => _
      end
    end
  end
end
