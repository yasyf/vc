class CompetitorLists::MostRecent < CompetitorLists::Base
  TITLE = 'Firms that recently made investments'

  def sql
    <<-SQL
      SELECT competitors.*
      FROM competitors
      INNER JOIN investments ON investments.competitor_id = competitors.id
      GROUP BY competitors.id, investments.funded_at
      ORDER BY investments.funded_at DESC
      LIMIT 10
    SQL
  end

  def meta_sql
    <<-SQL
      SELECT investments.funded_at, row_to_json(company.*) AS company
      FROM investments
      INNER JOIN (
        SELECT companies.id, companies.name, companies.domain, companies.description, companies.industry
        FROM companies
      ) AS company ON investments.company_id = company.id
      ORDER BY investments.funded_at DESC
      LIMIT 1
    SQL
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