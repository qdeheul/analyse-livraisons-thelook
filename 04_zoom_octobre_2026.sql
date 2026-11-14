-- Les trois délais et le volume, jour par jour, en octobre 2026
SELECT
  DATE(shipped_at) AS jour,
  ROUND(AVG(TIMESTAMP_DIFF(shipped_at, created_at, HOUR) / 24), 2) AS delai_preparation,
  ROUND(AVG(TIMESTAMP_DIFF(delivered_at, shipped_at, HOUR) / 24), 2) AS delai_transport,
  ROUND(AVG(TIMESTAMP_DIFF(delivered_at, created_at, HOUR) / 24), 2) AS delai_complet,
  COUNT(order_id) AS nb_commandes
FROM `bigquery-public-data.thelook_ecommerce.orders`
WHERE delivered_at IS NOT NULL
  AND DATE_TRUNC(DATE(shipped_at), MONTH) = '2026-10-01'
GROUP BY jour
ORDER BY jour;
