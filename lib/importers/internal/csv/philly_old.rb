require 'csv'
require 'open-uri'

module Importers::Internal::Csv
  class PhillyOld < BaseCsv
    HEADERS = {
      date: 'Date',
      product: 'Product',
      market: 'Market',
      team: 'Team',
      fit: 'Fit',
      overall: 'Overall',
      reason: 'Comments',
      company: 'Company',
      name: 'Name',
      type: 'Vote',
    }

    private

    def process!(parsed)
      super
      parsed[:overall] = nil if parsed[:type] == 'Pre'
      parsed
    end

    def team
      Team.phl
    end
  end
end
