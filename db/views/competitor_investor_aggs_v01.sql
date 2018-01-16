SELECT
  competitors.id AS competitor_id,
  COALESCE(SUM(investors.target_investors_count), 0) AS target_count,
  bool_or(COALESCE(investors.featured, false)) AS featured,
  bool_or(COALESCE(investors.verified, false)) AS verified
FROM competitors
  INNER JOIN investors ON investors.competitor_id = competitors.id
GROUP BY competitors.id