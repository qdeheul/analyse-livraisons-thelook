-- Les trois délais et le volume, par mois d'expédition
SELECT
  DATE_TRUNC(DATE(shipped_at), MONTH) AS mois,
  ROUND(AVG(TIMESTAMP_DIFF(shipped_at, created_at, HOUR) / 24), 2) AS delai_preparation,
  ROUND(AVG(TIMESTAMP_DIFF(delivered_at, shipped_at, HOUR) / 24), 2) AS delai_transport,
  ROUND(AVG(TIMESTAMP_DIFF(delivered_at, created_at, HOUR) / 24), 2) AS delai_complet,
  COUNT(order_id) AS nb_commandes
FROM `bigquery-public-data.thelook_ecommerce.orders`
WHERE delivered_at IS NOT NULL
GROUP BY mois
ORDER BY mois;
