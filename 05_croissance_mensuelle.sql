-- Taux de croissance du nombre de commandes livrées d'un mois sur l'autre
-- Étape 1 (CTE) : volume par mois. Étape 2 : LAG récupère le mois précédent.
WITH volume_mensuel AS (
  SELECT
    DATE_TRUNC(DATE(shipped_at), MONTH) AS mois,
    COUNT(order_id) AS nb_commandes
  FROM `bigquery-public-data.thelook_ecommerce.orders`
  WHERE delivered_at IS NOT NULL
  GROUP BY mois
)
SELECT
  mois,
  nb_commandes,
  ROUND(nb_commandes / LAG(nb_commandes) OVER (ORDER BY mois) * 100 - 100, 1) AS croissance_pct
FROM volume_mensuel
ORDER BY mois;
