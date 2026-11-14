-- Répartition des commandes livrées selon leur délai de transport
-- CEIL : tout jour entamé est compté. Part du total avec une fonction de fenêtre.
SELECT
  CEIL(TIMESTAMP_DIFF(delivered_at, shipped_at, HOUR) / 24) AS jours_transport,
  COUNT(order_id) AS nb_commandes,
  ROUND(COUNT(order_id) / SUM(COUNT(order_id)) OVER () * 100, 1) AS pct_total
FROM `bigquery-public-data.thelook_ecommerce.orders`
WHERE delivered_at IS NOT NULL
GROUP BY jours_transport
ORDER BY jours_transport;
