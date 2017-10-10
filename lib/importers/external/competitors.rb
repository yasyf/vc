module Importers::External
  class Competitors < Importers::Base
    HEADER_DEFAULTS = {
      name: 'investor_name',
      roles: 'roles',
      crunchbase_id: 'cb_url',
      type: 'investor_type',
      location: 'city',
      country: 'country',
    }

    TYPES = {
      accelerator: :accelerator,
      incubator: :accelerator,
      venture_capital: :venture,
      micro_vc: :seed,
      angel_group: :angel,
    }

    def self.process!(row)
      return false unless row.delete(:roles) == '{investor}'
      return false unless row[:type].present?
      row[:fund_type] = row.delete(:type)[1...-1].split(',').map { |t| TYPES[t.to_sym] }.compact
      return false unless row[:fund_type].present?
      row[:country] = Country.find_country_by_alpha3(row[:country]).alpha2 if row[:country].present?
      row[:crunchbase_id] = row[:crunchbase_id][26..-1]
    end

    def self.import!(row)
      competitor = Competitor.where(crunchbase_id: row[:crunchbase_id]).or(Competitor.where(name: row[:name])).first_or_initialize
      competitor.crunchbase_id = row[:crunchbase_id]
      competitor.name = row[:name]
      competitor.country = row[:country]
      competitor.location = (competitor.location || []) + [row[:location]] if row[:location].present?
      competitor.fund_type = (competitor.fund_type || []) + row[:fund_type]
      competitor.save! if competitor.changed?
    end
  end
end
