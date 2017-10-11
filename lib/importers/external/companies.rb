module Importers::External
  class Companies < Importers::Base
    HEADER_DEFAULTS = {
      name: 'company_name',
      roles: 'roles',
      crunchbase_id: 'permalink',
      domain: 'domain',
      description: 'short_description',
      categories: 'category_list',
      capital_raised: 'funding_total_usd',
      location: 'city',
      country: 'country_code',
    }

    def self.process!(row)
      return false unless row.delete(:roles) == '{company}'
      row[:industry] = row.delete(:categories).split(',').map { |c| Competitor.closest_industry(c) }.compact.uniq
      row[:country] = Country.find_country_by_alpha3(row[:country]).alpha2 if row[:country].present?
    end

    def self.import!(row)
      company = Company.where(crunchbase_id: row[:crunchbase_id]).or(Company.where(domain: row[:domain])).first_or_initialize
      company.crunchbase_id = row[:crunchbase_id]
      company.domain = row[:domain]
      company.name ||= row[:name]
      company.location ||= row[:location]
      company.description ||= row[:description]
      company.capital_raised = row[:capital_raised].present? ? row[:capital_raised] : 0
      company.industry = (company.industry || []) + row[:industry]
      company.save! if company.changed?
    end
  end
end
