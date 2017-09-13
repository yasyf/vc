module Importers::External
  class InvestorEmails < Importers::Base
    HEADER_DEFAULTS = {
      first_name: 'First Name',
      fund: 'Company',
      email: 'Email',
    }

    def self.process!(row)
      email = begin
        Mail::Address.new(row[:email])
      rescue Mail::Field::FieldError
        return false
      end

      row[:email] = email.address
      row[:competitor] = Competitor.create_from_domain!( email.domain, row.delete(:fund))
    end

    def self.import!(row)
      return unless row[:competitor].present?
      scope = Investor.where(row.except(:email).select {|k,v| v.present? })
      scope.update_all(email: row[:email]) if scope.count == 1
    end
  end
end
