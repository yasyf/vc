class CompetitorLists::MostPopular < CompetitorLists::Base
  TITLE = 'Firms that are popular'

  def title
    "#{TITLE} in #{cache_values[:city]}"
  end

  def self._eligible?(attrs)
    return false unless attrs[:city].present?
    sql = <<-SQL
      SELECT COUNT(*) FROM (#{_sql(attrs)}) AS subquery
    SQL
    Competitor.connection.select_value(sql) > 0
  end

  def self.cache_key_attrs
    [:city]
  end

  def self.cache_key_fallbacks
    {
      city: Proc.new { |request| Geocoder.search("New York").first&.city }
    }
  end

  def self._sql(attrs)
    Competitor
      .where('competitors.location && ?', "{#{attrs[:city]}}")
      .joins(:companies)
      .joins(:investors)
      .where('companies.location = ?', attrs[:city])
      .order('ti_sum DESC, c_cnt DESC')
      .group('competitors.id')
      .select('competitors.id', 'COALESCE(SUM(investors.target_investors_count), 0) AS ti_sum', 'COUNT(companies.id) AS c_cnt')
      .limit(10)
      .to_sql
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
      FROM (#{self.class._sql(cache_values)}) AS subquery
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