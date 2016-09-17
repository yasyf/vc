require 'csv'
require 'open-uri'

module Importers::Csv
  class Philly < BaseCsv
    HEADERS = {
      date: 'Timestamp',
      email: 'Username',
      product: 'Product',
      market: 'Market',
      team: 'Team',
      fit: 'Fit',
      overall: 'Overall',
      reason: 'Comments?',
      company: 'Company',
    }

    private

    def team
      Team.phl
    end
  end
end
