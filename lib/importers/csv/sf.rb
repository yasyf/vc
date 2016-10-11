require 'csv'
require 'open-uri'

module Importers::Csv
  class Sf < BaseCsv
    HEADERS = {
      date: 'Timestamp',
      product: 'Product',
      market: 'Market',
      team: 'Team',
      fit: 'DRF Fit',
      overall: 'Vote',
      reason: 'Investment Thesis',
      company: 'Company Name',
      name: 'Your Name',
      type: 'Pre-vote or Post-vote?',
    }

    private

    def process!(parsed)
      super
      parsed[:final] = parsed[:type] == 'Post-Vote'
      parsed[:overall] = parsed[:overall] == 'Yes' ? 5 : 1
      parsed
    end

    def team
      Team.sf
    end
  end
end
