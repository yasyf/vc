class CompetitorLists::Single < CompetitorLists::Base::Base
  TITLE = 'Single'

  def initialize(founder, request, id)
    super founder, request
    @id = id
  end

  def self._eligible?(attrs)
    false
  end

  def title
    competitor.name
  end

  def description
    "Learn about #{competitor.name} on VCWiz. #{(competitor.description || '').squish.truncate(150)}"
  end

  def sql
    Competitor.where(id: @id).to_sql
  end

  private

  def competitor
    @competitor ||= Competitor.find(@id)
  end
end