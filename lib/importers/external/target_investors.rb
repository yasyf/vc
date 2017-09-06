require 'csv'
require 'open-uri'

module Importers::External
  class TargetInvestors < Importers::Base
    MAX_DISTANCE = 3
    HEADERS = {
     first_name: ['First Name'],
     last_name: ['Last Name'],
     name: ['Full Name', 'Name'],
     role: %w(Title Role),
     email: ['Email', 'Email Address'],
     firm: %w(Firm Fund VC Company Organization),
     note: %w(Note Comment)
    }

    def self.headers
      HEADERS.transform_values(&:first)
    end

    def initialize(f, founder)
      @filename = file?(f) || url?(f) ? save(f) : f
      @founder = founder
    end

    def import!(headers, header_row)
      count = 0
      ::CSV.foreach(@filename).map do |rrow|
        count += 1
        next if header_row && count == 1
        row = rrow.each_with_index.map { |x, i| [headers[i.to_s], x] if i.to_s.in?(headers) }.compact.to_h
        import_row! row.with_indifferent_access
      end.compact
    end

    def parse!
      csv = ::CSV.foreach(@filename, headers: false)
      headers = csv.first
      return [{ error: true, message: 'CSV is empty' }, {}] unless headers.present?

      suggestions = {}
      headers.each_with_index do |header, i|
        matches = []
        HEADERS.each do |k, v|
          next if k.in? suggestions.values
          v.each do |s|
            distance = Levenshtein.distance(s.downcase, header.downcase)
            matches.push([k, distance]) if distance <= MAX_DISTANCE
          end
        end
        suggestions[i] = matches.min_by(&:last).first if matches.present?
      end

      [{
        error: false,
        suggestions: suggestions,
        samples: csv.drop(1).first(3)
      }, {
        filename: @filename,
        header_row: suggestions.present?
      }]
    end

    private

    def import_row!(row)
      name = (row[:name] || '').split(' ')
      email = Mail::Address.new(row[:email]).address rescue nil
      TargetInvestor.create!(
        founder: @founder,
        first_name: row[:first_name] || name.first,
        last_name: row[:last_name] || name.drop(1).join(' '),
        firm_name: row[:firm],
        role: row[:role],
        email: email,
        note: row[:note]
      )
    rescue ActiveRecord::RecordNotUnique
      nil
    end
  end
end
