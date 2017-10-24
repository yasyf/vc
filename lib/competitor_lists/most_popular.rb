class CompetitorLists::MostPopular < CompetitorLists::Base
  TITLE = 'Firms that are popular'

  def title
    "#{TITLE} in #{founder.city}"
  end

  def self.eligible?(founder)
    return false unless founder.city.present?
    sql = <<-SQL
      SELECT COUNT(*) FROM (#{_sql(founder)}) AS subquery
    SQL
    Competitor.connection.select_value(sql) > 0
  end

  def self._sql(founder)
    by_location = Competitor.where('competitors.location && ?', "{#{founder.city}}").select('competitors.id').limit(10).to_sql
    by_company = Competitor.joins(:companies).where('companies.location = ?', founder.city).select('competitors.id').limit(10).to_sql
    <<-SQL
      (#{by_location}) UNION (#{by_company})
    SQL
  end

  def sort
    <<-SQL
      COALESCE(SUM(investors.target_investors_count), 0) DESC, COUNT(companies.id) DESC
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
      FROM (#{self.class._sql(founder)}) AS subquery
      LEFT OUTER JOIN investors ON investors.competitor_id = subquery.id
      LEFT OUTER JOIN investments ON investments.competitor_id = subquery.id
      LEFT OUTER JOIN companies ON companies.id = investments.company_id
      GROUP BY subquery.id
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