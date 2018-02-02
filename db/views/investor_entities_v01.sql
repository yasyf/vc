SELECT
  competitors.id AS competitor_id,
  investors.id AS investor_id,
  entities.id AS entity_id,
  COALESCE(MAX(investor_person_entities.count), 0) + COALESCE(MAX(post_person_entities.count), 0) AS count
FROM investors
LEFT OUTER JOIN posts ON posts.investor_id = investors.id
LEFT OUTER JOIN person_entities AS investor_person_entities ON investor_person_entities.person_type = 'Investor' AND investor_person_entities.person_id = investors.id
LEFT OUTER JOIN person_entities AS post_person_entities ON post_person_entities.person_type = 'Post' AND post_person_entities.person_id = posts.id
INNER JOIN entities ON investor_person_entities.entity_id = entities.id OR post_person_entities.entity_id = entities.id
INNER JOIN competitors ON competitors.id = investors.competitor_id
GROUP BY competitors.id, investors.id, entities.id