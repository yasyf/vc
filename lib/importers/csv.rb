require 'csv'
require 'open-uri'

module Importers
  class Csv < VotingBase
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

    def initialize(filename, team_name)
      @filename = url?(filename) ? save(filename) : filename
      @team_name = team_name
    end

    def sync!
      ::CSV.foreach(@filename, headers: true) do |row|
        parsed = HEADERS.map { |h,s| [h, row[s].try(:strip)] }.to_h
        import! parsed
      end
    end

    private

    def team
      Team.send(@team_name)
    end
  end
end
