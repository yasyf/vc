SELECT
  competitors.id AS competitor_id,
  COUNT(investments.id) AS velocity
FROM competitors
INNER JOIN investments ON investments.competitor_id = competitors.id
GROUP BY competitors.id