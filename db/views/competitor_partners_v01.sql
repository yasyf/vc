SELECT
  competitors.id AS competitor_id,
  partners_join.partners_arr AS partners
FROM competitors
LEFT JOIN LATERAL (
  WITH
      partners_results AS (
        SELECT id, role
        FROM investors
        WHERE investors.competitor_id = competitors.id
    ),
      filtered_partners_results AS (
        SELECT * FROM partners_results
        WHERE LOWER(partners_results.role) ILIKE ANY (ARRAY['%managing%', '%partner%', '%director%', '%associate%', '%principal%', '%ceo%', '%founder%', '%invest%'])
    ),
      all_ids AS (
      SELECT id FROM filtered_partners_results
      UNION
      SELECT id FROM partners_results
      WHERE NOT EXISTS (SELECT * FROM filtered_partners_results)
    ),
      all_partners AS (
        SELECT investors.id, investors.first_name, investors.last_name, investors.photo, investors.role, investors.verified
        FROM investors
          INNER JOIN all_ids ON investors.id = all_ids.id
          LEFT OUTER JOIN investments ON investments.investor_id = investors.id
        GROUP BY investors.id
        ORDER BY
          investors.featured DESC,
          investors.verified DESC,
          MAX(investments.funded_at) DESC NULLS LAST,
          COUNT(investments.id) DESC
        LIMIT 25
    )
  SELECT array_to_json(array_agg(all_partners)) AS partners_arr
  FROM all_partners
) AS partners_join ON true