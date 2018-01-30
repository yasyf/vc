SELECT
  competitors.id AS competitor_id,
  COUNT(investments.id) AS velocity
FROM competitors
INNER JOIN investments ON investments.competitor_id = competitors.id
WHERE investments.funded_at > (now() - interval '1 year')
GROUP BY competitors.id