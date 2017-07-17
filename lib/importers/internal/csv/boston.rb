require 'csv'
require 'open-uri'

module Importers::Internal::Csv
  class Boston < BaseCsv
    HEADERS = {
      date: 'Date',
      email: 'Username',
      product: 'Product',
      market: 'Market',
      team: 'Team',
      fit: 'Fit',
      overall: 'Overall',
      reason: 'Reason For Voting',
      company: 'Company'
    }
  end

  private

  def team
    Team.boston
  end
end
