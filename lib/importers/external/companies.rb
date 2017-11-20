module Importers::External
  class Companies < Importers::Base
    HEADER_DEFAULTS = {
      name: 'company_name',
      role: 'primary_role',
      crunchbase_id: 'permalink',
      domain: 'domain',
      description: 'short_description',
      categories: 'category_list',
      capital_raised: 'funding_total_usd',
      location: 'city',
      country: 'country_code',
    }

    def self.process!(row)
      return false unless row.delete(:role) == 'company'
      row[:industry] = row.delete(:categories).split(',').map { |c| Competitor.closest_industry(c) }.compact.uniq if row[:categories].present?
      row[:country] = Country.find_country_by_alpha3(row[:country])&.alpha2 if row[:country].present?
      row[:crunchbase_id] = row[:crunchbase_id].split('/').last if row[:crunchbase_id].present?
    end

    def self.import!(row)
      company = nil
      company = Company.where(crunchbase_id: row[:crunchbase_id]).first if row[:crunchbase_id].present?
      company = Company.where(domain: row[:domain]).first if company.blank? && row[:domain].present?
      company = Company.new if company.blank?
      company.crunchbase_id = row[:crunchbase_id]
      company.domain = row[:domain]
      company.name ||= row[:name]
      company.location ||= row[:location]
      company.description ||= row[:description]
      company.capital_raised = row[:capital_raised].present? ? row[:capital_raised] : 0
      company.industry = (company.industry || []) + (row[:industry] || [])
      company.save! if company.changed?
    end
  end
end
