-- Nombre de commandes par statut
-- Seuls Complete et Returned ont une date de livraison : ce sont eux qui servent aux délais.
SELECT
  status,
  COUNT(status) AS nb_commandes
FROM `bigquery-public-data.thelook_ecommerce.orders`
GROUP BY status
ORDER BY nb_commandes DESC;
