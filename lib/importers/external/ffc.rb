module Importers::External
  class FFC < Importers::Base
    extend Concerns::Ignorable

    HEADER_DEFAULTS = {
      full_name: 'Name',
      title: 'Title',
      tags: 'Diversity Flag',
      firm: 'Firm',
      crunchbase: 'Crunchbase URL',
      linkedin: 'LinkedIn URL',
    }

    def self.ids
      @ids ||= Set.new
    end

    def self.csv
      Investor.where(id: ids).to_csv
    end

    def self.process!(row)
      row[:tags] = row[:tags].split(',')
      row[:competitor] = Competitor.create_from_name!(row[:firm]) if row[:firm].present?
      first_name, last_name = Util.split_name(row[:full_name])

      row[:investor] = (
        (row[:competitor].present? && ignore_record_errors { Investor.create_for_competitor!(row[:competitor], first_name, last_name) }) ||
        (row[:crunchbase].present? && ignore_record_errors { Investor.from_crunchbase(row[:crunchbase].split('/').last) }) ||
        Investor.from_name(row[:full_name])
      )

      return row[:investor].present?
    end

    def self.import!(row)
      ignore_unique do
        row[:investor].update!(
          tags: row[:tags],
          crunchbase_id: row[:crunchbase],
          linkedin: row[:linkedin],
          role: row[:title],
        )
      end
      if row[:competitor].present?
        ignore_unique { row[:investor].update! competitor: row[:competitor] }
      end
      ids << row[:investor].id
    end
  end
end
