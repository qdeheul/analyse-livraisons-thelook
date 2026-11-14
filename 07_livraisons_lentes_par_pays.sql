-- Part des livraisons lentes (plus de 4 jours de transport, jour entamé compté) par pays,
-- puis classement du pays le plus lent au plus rapide.
WITH lenteur_par_pays AS (
  SELECT
    u.country,
    ROUND(AVG(TIMESTAMP_DIFF(o.delivered_at, o.shipped_at, HOUR) / 24), 2) AS delai_moyen,
    COUNT(o.order_id) AS nb_commandes,
    ROUND(
      COUNT(CASE WHEN CEIL(TIMESTAMP_DIFF(o.delivered_at, o.shipped_at, HOUR) / 24) > 4 THEN o.order_id END)
      / COUNT(o.order_id) * 100, 2
    ) AS pct_livraisons_lentes
  FROM `bigquery-public-data.thelook_ecommerce.orders` AS o
  INNER JOIN `bigquery-public-data.thelook_ecommerce.users` AS u
    ON o.user_id = u.id
  WHERE o.delivered_at IS NOT NULL
  GROUP BY u.country
  HAVING COUNT(o.order_id) > 500
)
SELECT
  RANK() OVER (ORDER BY pct_livraisons_lentes DESC) AS rang_lenteur,
  *
FROM lenteur_par_pays
ORDER BY rang_lenteur;
