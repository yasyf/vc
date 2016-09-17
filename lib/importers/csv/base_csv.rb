require 'csv'
require 'open-uri'

module Importers::Csv
  class BaseCsv < Importers::VotingBase
    def initialize(filename, emails_filename = nil)
      @filename = url?(filename) ? save(filename) : filename
      @emails_filename = emails_filename && url?(emails_filename) ? save(emails_filename) : emails_filename
    end

    def emails
      if @emails_filename.present?
        @emails ||= ::CSV.read(@emails_filename).drop(1).map { |row| row.first(2).reverse }.to_h
      end
    end

    def process!(parsed)
      parsed[:email] ||= extract_email(parsed[:name], emails) if parsed[:name].present?
      parsed
    end

    def sync!
      ::CSV.foreach(@filename, headers: true) do |row|
        parsed = self.class::HEADERS.map { |h,s| [h, row[s].try(:strip)] }.to_h
        parsed = process! parsed
        import! parsed
      end
    end
  end
end
