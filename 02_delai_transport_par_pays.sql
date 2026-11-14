-- Délai moyen de transport par pays (pays avec plus de 500 commandes livrées)
-- Calcul en heures / 24 : plus précis qu'en jours entiers.
SELECT
  u.country,
  ROUND(AVG(TIMESTAMP_DIFF(o.delivered_at, o.shipped_at, HOUR) / 24), 2) AS delai_transport_jours,
  COUNT(o.order_id) AS nb_commandes
FROM `bigquery-public-data.thelook_ecommerce.orders` AS o
INNER JOIN `bigquery-public-data.thelook_ecommerce.users` AS u
  ON o.user_id = u.id
WHERE o.delivered_at IS NOT NULL
GROUP BY u.country
HAVING COUNT(o.order_id) > 500
ORDER BY delai_transport_jours DESC;
