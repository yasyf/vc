module Importers::External
  class Investments < Importers::Base
    HEADER_DEFAULTS = {
      partner_name: 'Partner #1',
      firm_name: 'Investor',
      company_name: 'Company',
      funded_at: 'Announce Date',
      series: 'Series',
      location: 'City',
      industries: 'All Categories',
    }

    def initialize(filename, headers = {}, featured: true, sep: '|')
      super(filename, headers)
      @featured = featured
      @sep = sep
    end

    def preprocess(row)
      super(row).tap do |parsed|
        parsed[:featured] = @featured
        parsed[:industries] = parsed[:industries].split(@sep)
      end
    end

    def self.process!(row)
      puts row.to_s

      name = Util.split_name(row.delete(:partner_name))
      company_name = row.delete(:company_name)

      row[:competitor] = Competitor.create_from_name!(row.delete(:firm_name))
      row[:investor] = Investor.create_for_competitor!(row[:competitor], name.first, name.last)
      row[:company] = row[:competitor].companies.where(name: company_name) || Company.from_name(company_name)

      row[:industry] = row.delete(:industries).map { |i| Competitor.closest_industry(i) }.compact.uniq
    end

    def self.import!(row)
      row[:company].industry += row[:industry]
      row[:company].save!

      row[:company].founders.each do |founder|
        founder.city ||= row[:location]
        founder.save!
      end

      row[:investor].location ||= row[:location]
      row[:investor].save!

      row[:competitor].location << row[:location]
      row[:competitor].save!

      investment = Investment.where(row.slice(:company, :competitor)).first_or_initialize
      investment.investor ||= row[:investor]
      investment.funded_at = row[:funded_at]
      investment.funding_type = row[:series] == 'Seed' ? :seed : :venture
      investment.series = row[:series] == 'Seed' ? nil : row[:series]
      investment.featured = parsed[:featured]
      investment.save!
    end
  end
end