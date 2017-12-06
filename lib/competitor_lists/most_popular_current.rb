class CompetitorLists::MostPopularCurrent < CompetitorLists::MostPopular
  def title
    "#{TITLE} in #{@request.session[:city]}"
  end

  def description
    """
      These are the most popular firms in your current city of #{@request.session[:city]}!
      You might want to check them out while you're in town.
    """
  end

  def self.personalized?
    true
  end

  def self.eligible?(founder, request)
    request.present? && request.session[:city] != cache_values(founder, request)[:city] && _eligible?(city: request.session[:city])
  end

  def _sql
    self.class._sql(city: @request.session[:city])
  end
end