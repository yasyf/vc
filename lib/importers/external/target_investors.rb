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

    def initialize(f)
      @filename = file?(f) || url?(f) ? save(f) : f
    end

    def parse!
      csv = ::CSV.foreach(@filename, headers: false)
      headers = csv.first
      return { error: true, message: 'CSV is empty' } unless headers.present?

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

      { error: false, suggestions: suggestions,  samples: csv.drop(1).first(3) }
    end
  end
end
