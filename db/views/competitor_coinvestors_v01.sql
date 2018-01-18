SELECT
  competitors.id AS competitor_id,
  coinvestors_join.coi_arr AS coinvestors
FROM competitors
LEFT JOIN LATERAL (
  WITH
    comp_companies AS (
      SELECT companies.id
      FROM companies
      INNER JOIN investments ON investments.company_id = companies.id
      WHERE investments.competitor_id = competitors.id
    ),
    comp_coinvestors AS (
      SELECT coinvestors.id, coinvestors.name, COUNT(investments.id) AS overlap
      FROM investments
      INNER JOIN comp_companies ON comp_companies.id = investments.company_id
      INNER JOIN competitors AS coinvestors ON coinvestors.id = investments.competitor_id
      WHERE coinvestors.id != competitors.id
      GROUP BY coinvestors.id
      ORDER BY COUNT(investments.id) DESC
      LIMIT 5
    )
  SELECT array_to_json(array_agg(comp_coinvestors)) AS coi_arr
  FROM comp_coinvestors
) AS coinvestors_join ON true