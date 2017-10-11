class CompetitorLists::MostRecent < CompetitorLists::Base
  TITLE = 'Firms that recently made investments'

  def self.sql
    Competitor.joins(:investments).order('investments.funded_at DESC').limit(10).to_sql
  end
end