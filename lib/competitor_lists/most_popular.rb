class CompetitorLists::MostPopular < CompetitorLists::Base::Base
  TITLE = 'Firms that are popular'

  def title
    "#{TITLE} in #{cache_values[:city]}"
  end

  def description
    """
      These are the most popular firms in #{cache_values[:city]}!
      People both on and off the VCWiz platform seem to prefer them for investment.
    """
  end

  def self.personalized?
    true
  end

  def self._eligible?(attrs)
    return false unless attrs[:city].present?
    sql = <<-SQL
      SELECT COUNT(*) FROM (#{_sql(attrs)}) AS subquery
    SQL
    Competitor.connection.select_value(sql) > 0
  end

  def self.cache_values_span
    Competitor.locations(nil, nil).map { |l| { city: l } }
  end

  def self.cache_key_attrs
    {
      city: Proc.new { |founder| founder.primary_company&.location || founder.city }
    }
  end

  def self.cache_key_fallbacks
    {
      city: Proc.new { |request| request.session[:city] }
    }
  end

  def self._sql(attrs)
    Competitor
      .joins(:companies)
      .where('competitors.location && ?', "{#{attrs[:city]}}")
      .or(Competitor.joins(:companies).where('companies.location IN (?)', attrs[:city]))
      .joins(:investors)
      .joins("LEFT OUTER JOIN companies AS city_companies ON (city_companies.id = investments.company_id AND #{Util.sanitize_sql('city_companies.location = ?', attrs[:city])})")
      .select('competitors.id', 'COALESCE(SUM(investors.target_investors_count), 0) AS ti_sum', 'COUNT(city_companies.id) AS c_cnt')
      .order('ti_sum DESC, c_cnt DESC')
      .group('competitors.id')
      .limit(10)
      .to_sql
  end

  def _sql
    self.class._sql(cache_values)
  end

  def sort
    <<-SQL
      subquery.ti_sum DESC, subquery.c_cnt DESC
    SQL
  end

  def order_sql
    <<-SQL
      row_number() OVER (ORDER BY #{sort}) AS rn
    SQL
  end

  def with_order_subquery
    <<-SQL
      SELECT subquery.id, #{order_sql}
      FROM (#{_sql}) AS subquery
      LIMIT 10
    SQL
  end

  def sql
    <<-SQL
      SELECT competitors.*, wo.rn
      FROM (#{with_order_subquery}) AS wo
      INNER JOIN competitors USING (id)
    SQL
  end

  def order
    :rn
  end
end