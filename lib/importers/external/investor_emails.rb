require 'csv'
require 'open-uri'

module Importers::External
  class InvestorEmails < Importers::Base
    HEADER_DEFAULTS = {
      first_name: 'First Name',
      fund: 'Company',
      email: 'Email',
    }

    def initialize(filename, headers = {})
      @filename = url?(filename) ? save(filename) : filename
      @headers = headers.with_indifferent_access.slice(*HEADER_DEFAULTS.keys).reverse_merge(HEADER_DEFAULTS)
    end

    def process!(row)
      row[:email] = Mail::Address.new(row[:email]).address rescue nil
      row[:competitor] = Competitor.create_from_domain!( row[:email].split('@').last, row.delete(:fund))
    end

    def import!(row)
      Rails.logger.info row
      return unless row[:competitor].present?
      scope = Investor.where(row.except(:email).select {|k,v| v.present? })
      scope.update_all(email: row[:email]) if scope.count == 1
    end

    def sync!
      ::CSV.foreach(@filename, headers: true) do |row|
        parsed = @headers.map { |h,s| [h, row[s].try(:strip)] }.to_h.compact.with_indifferent_access
        process! parsed
        import! parsed
      end
    end
  end
end
