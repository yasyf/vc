module Importers::External
  class FFC < Importers::Base
    HEADER_DEFAULTS = {
      full_name: 'Name',
      title: 'Title',
      tags: 'Diversity Flag',
      firm: 'Firm',
      crunchbase: 'Crunchbase URL',
      linkedin: 'LinkedIn URL',
    }

    def self.ids
      @ids = Set.new
    end

    def self.csv
      Investor.where(id: ids).to_csv
    end

    def self.process!(row)
      row[:tags] = row[:tags].split(',')

      first_name, last_name = Util.split_name(row[:full_name])
      if row[:crunchbase].present?
        row[:investor] = Investor.from_crunchbase(row[:crunchbase].split('/').last)
      end
      unless row[:investor].present?
        competitor = Competitor.create_from_name!(row[:firm])
        row[:investor] = (
          Investor.from_name(row[:full_name]) ||
          Investor.create_for_competitor!(competitor, first_name, last_name)
        )
      end

      return row[:investor].present?
    end

    def self.import!(row)
      row[:investor].update!(
        tags: row[:tags],
        crunchbase_id: row[:crunchbase],
        linkedin: row[:linkedin],
        role: row[:title],
      )
      ids << row[:investor].id
    end
  end
end
