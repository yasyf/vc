class CompetitorLists::MostRecent < CompetitorLists::Base::Base
  TITLE = 'Firms that recently made investments'

  def description
    'These are the most recent investments made anywhere in the country. What a great way to keep tabs on venture activity!'
  end

  def self.cache_key_attrs
    true
  end

  def sort
    <<-SQL
      investments.funded_at DESC NULLS LAST,
      investments.featured DESC,
      COUNT(NULLIF(investors.featured, false)) DESC,
      COUNT(NULLIF(investors.verified, false)) DESC,
      SUM(COALESCE(competitor_target_counts.target_count, 0)) DESC
    SQL
  end

  def join
    <<-SQL
      INNER JOIN competitors ON competitors.id = investments.competitor_id
      INNER JOIN competitor_target_counts ON competitor_target_counts.competitor_id = competitors.id
      LEFT OUTER JOIN investors ON investors.competitor_id = competitors.id
    SQL
  end

  def limited_sql
    <<-SQL
      SELECT investments.id
      FROM investments
      ORDER BY funded_at DESC NULLS LAST
      LIMIT 100
    SQL
  end

  def distinct_sql
    uniqued_on_company = <<-SQL
      SELECT DISTINCT ON(investments.company_id) investments.id
      FROM investments
      INNER JOIN (#{limited_sql}) AS limited ON limited.id = investments.id
      #{join}
      GROUP BY investments.id
      ORDER BY investments.company_id DESC, #{sort}
    SQL
    uniqued = <<-SQL
      SELECT DISTINCT ON(competitors.id) investments.id
      FROM investments
      INNER JOIN (#{uniqued_on_company}) AS uniqued_on_company ON uniqued_on_company.id = investments.id
      #{join}
      GROUP BY competitors.id, investments.id
      ORDER BY competitors.id DESC, #{sort}
    SQL
    <<-SQL
      SELECT investments.id, row_number() OVER (ORDER BY #{sort}) AS rn
      FROM investments
      INNER JOIN (#{uniqued}) AS uniqued ON uniqued.id = investments.id
      #{join}
      GROUP BY investments.id
      LIMIT 10
    SQL
  end

  def sql
    <<-SQL
      SELECT competitors.*, investments.id AS investment_id, di.rn
      FROM (#{distinct_sql}) AS di
      INNER JOIN investments ON di.id = investments.id
      INNER JOIN competitors ON competitors.id = investments.competitor_id
    SQL
  end

  def meta_sql
    <<-SQL
      SELECT investments.funded_at, row_to_json(company.*) AS company
      FROM investments
      INNER JOIN (
        SELECT companies.id, companies.name, companies.domain, companies.description, companies.industry
        FROM companies
      ) AS company ON company.id = investments.company_id
      WHERE investments.id = subquery.investment_id
    SQL
  end

  def order
    :rn
  end

  def meta_cols
    [
      {
        key: :funded_at,
        name: 'Funding Date',
        type: :datetime,
      },
      {
        key: :company,
        name: 'Company',
        type: :company,
      }
    ]
  end
end