module Importers::External
  class Competitors < Importers::Base
    HEADER_DEFAULTS = {
      name: 'investor_name',
      roles: 'roles',
      crunchbase_id: 'cb_url',
      type: 'investor_type',
      location: 'city',
      country: 'country_code',
    }



    def self.process!(row)
      return false unless row.delete(:roles) == 'investor'
      return false unless row[:type].present?
      row[:fund_type] = row.delete(:type).split(',').map { |t| Http::Crunchbase::Fund::TYPES[t.to_sym] }.compact
      return false unless row[:fund_type].present?
      row[:country] = Country.find_country_by_alpha3(row[:country])&.alpha2 if row[:country].present?
      row[:crunchbase_id] = row[:crunchbase_id].split('/').last if row[:crunchbase_id].present?
    end

    def self.import!(row)
      competitor = nil
      competitor = Competitor.where(crunchbase_id: row[:crunchbase_id]).first if row[:crunchbase_id].present?
      competitor = Competitor.where(name: row[:name]).first if competitor.blank? && row[:name].present?
      competitor = Competitor.new if competitor.blank?
      competitor.crunchbase_id = row[:crunchbase_id]
      competitor.name = row[:name]
      competitor.country = row[:country]
      competitor.location = (competitor.location || []) + [row[:location]] if row[:location].present?
      competitor.fund_type = (competitor.fund_type || []) + row[:fund_type]
      competitor.save! if competitor.changed?
    end
  end
end
