class CompetitorLists::MostPopularCurrent < CompetitorLists::MostPopular
  def title
    "#{TITLE} in #{@request.session[:city]}"
  end

  def self.eligible?(founder, request)
    request.present? && request.session[:city] != cache_values(founder, request)[:city] && _eligible?(city: request.session[:city])
  end

  def _sql
    self.class._sql(city: request.session[:city])
  end
end