require 'csv'
require 'open-uri'

module Importers::External
  class InvestorEmails < Importers::Base
    HEADER_DEFAULTS = {
      first_name: 'First Name',
      fund: 'Company',
      email: 'Email',
    }

    def self.process!(row)
      begin
        row[:email] = Mail::Address.new(row[:email]).address
      rescue Mail::Field::FieldError
        return false
      end
      row[:competitor] = Competitor.create_from_domain!( row[:email].split('@').last, row.delete(:fund))
    end

    def self.import!(row)
      return unless row[:competitor].present?
      scope = Investor.where(row.except(:email).select {|k,v| v.present? })
      scope.update_all(email: row[:email]) if scope.count == 1
    end
  end
end
