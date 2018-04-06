SELECT
  founders.id AS founder_id,
  primary_companies.company_id AS company_id
FROM founders
LEFT JOIN LATERAL (
  SELECT companies_founders.company_id
  FROM companies_founders
  INNER JOIN companies ON companies.id = companies_founders.company_id
  WHERE founders.id = companies_founders.founder_id
  ORDER BY
    companies.primary DESC,
    companies.created_at DESC
  LIMIT 1
) AS primary_companies ON true
