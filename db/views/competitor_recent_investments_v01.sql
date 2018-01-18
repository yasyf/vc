SELECT
  competitors.id AS competitor_id,
  recent_investments_join.ri_arr AS recent_investments
FROM competitors
LEFT JOIN LATERAL (
  WITH
    recent_investments AS (
      SELECT companies.id, companies.name, companies.domain, companies.crunchbase_id
      FROM companies
      INNER JOIN investments ON investments.company_id = companies.id
      WHERE investments.competitor_id = competitors.id
      GROUP BY companies.id
      ORDER BY
        MAX(investments.funded_at) DESC NULLS LAST,
        COUNT(NULLIF(investments.featured, false)) DESC,
        companies.capital_raised DESC,
        COUNT(investments.id) DESC
      LIMIT 5
    )
  SELECT array_to_json(array_agg(recent_investments)) AS ri_arr
  FROM recent_investments
) AS recent_investments_join ON true