SELECT
  competitors.id AS competitor_id,
  COALESCE(SUM(investors.target_investors_count), 0) AS target_count
FROM competitors
INNER JOIN investors ON investors.competitor_id = competitors.id
GROUP BY competitors.id