# Analyse des délais de livraison d'une boutique en ligne (SQL, BigQuery)

Entre 2020 et 2026, la boutique a absorbé une hausse de volume de x30 en gardant un délai de livraison stable d'environ 4 jours. Ce projet le montre en SQL, puis va au-delà de la moyenne : répartition des délais, livraisons lentes par pays et vérification d'une anomalie de volume.

## Question

Les délais de préparation et de transport d'une boutique en ligne tiennent-ils face à la croissance des commandes ?

## Données

- **Source :** jeu public `bigquery-public-data.thelook_ecommerce` (Google BigQuery)
- **Tables utilisées :** `orders` (commandes) et `users` (clients, pour le pays), reliées par `orders.user_id = users.id`
- **Outil :** BigQuery Sandbox (GoogleSQL)

> ⚠️ **Données fictives et régénérées.** TheLook est une boutique en ligne inventée par l'équipe Looker. Ses données sont synthétiques et sont rafraîchies chaque jour : l'historique entier change d'une exécution à l'autre. Les étapes 1 à 4 ont été exécutées début novembre 2026, les étapes 5 à 7 le 14 novembre 2026. Les chiffres obtenus en relançant les requêtes seront différents.

**Périmètre :** seules les commandes livrées (`delivered_at` renseigné, statuts Complete et Returned) servent à calculer des délais.

## Les trois délais mesurés

| Délai | Calcul |
| --- | --- |
| Préparation | `shipped_at` − `created_at` |
| Transport | `delivered_at` − `shipped_at` |
| Complet (attente du client) | `delivered_at` − `created_at` |

Les délais sont calculés en heures, puis divisés par 24 : un calcul en jours entiers sous-estimait le transport d'environ un demi-jour.

## Analyses

| # | Analyse | Fichier | Notions SQL |
| --- | --- | --- | --- |
| 1 | Statuts des commandes | [`01_statuts.sql`](sql/01_statuts.sql) | `GROUP BY`, `COUNT` |
| 2 | Délai de transport par pays | [`02_delai_transport_par_pays.sql`](sql/02_delai_transport_par_pays.sql) | `INNER JOIN`, `HAVING`, `TIMESTAMP_DIFF` |
| 3 | Évolution mensuelle des trois délais | [`03_evolution_mensuelle_delais.sql`](sql/03_evolution_mensuelle_delais.sql) | `DATE_TRUNC`, agrégats |
| 4 | Zoom jour par jour sur octobre 2026 | [`04_zoom_octobre_2026.sql`](sql/04_zoom_octobre_2026.sql) | filtres de dates |
| 5 | Croissance d'un mois sur l'autre | [`05_croissance_mensuelle.sql`](sql/05_croissance_mensuelle.sql) | CTE, `LAG` |
| 6 | Répartition des délais de transport | [`06_repartition_delais.sql`](sql/06_repartition_delais.sql) | `CEIL`, `SUM(...) OVER ()` |
| 7 | Livraisons lentes par pays | [`07_livraisons_lentes_par_pays.sql`](sql/07_livraisons_lentes_par_pays.sql) | CTE, `CASE WHEN` dans un agrégat, `RANK` |

## Résultats

### 1. Des délais stables malgré la croissance

Depuis mi-2020, le délai complet reste autour de **4 jours** : environ 1,5 jour de préparation et 2,5 jours de transport. Pendant ce temps, le volume mensuel de commandes livrées est passé de 62 (janvier 2020) à 1 873 (septembre 2026), soit **x30**. La logistique a absorbé cette montée en charge sans dégrader ses délais.

Le **transport représente environ 60 %** de l'attente du client : c'est le premier levier pour livrer plus vite, même s'il dépend souvent de transporteurs extérieurs.

Avant mi-2020, les volumes sont trop faibles (5 à 77 commandes par mois) pour tirer des conclusions : les délais y varient fortement d'un mois à l'autre.

### 2. Des délais homogènes entre pays

Dans les 11 pays ayant plus de 500 commandes livrées, le transport prend entre **2,46 et 2,51 jours** en moyenne. La Pologne (108 commandes) et la Colombie (7) ont été exclues : leurs moyennes plus élevées reposent sur un échantillon trop petit.

### 3. Une anomalie de volume liée à la génération des données

Début novembre, octobre 2026 affichait **+84 %** de commandes par rapport à septembre, alors que la croissance habituelle tourne entre −10 % et +20 % par mois. Le détail jour par jour montrait un pic sur les derniers jours du mois, suivi d'un allongement du délai de préparation (2,1 et 2,6 jours, contre 1,5 habituellement), cohérent avec un retard accumulé en entrepôt.

Refaite le 14 novembre, la même analyse donne seulement **+19,9 %** pour octobre, et le pic s'est déplacé sur **novembre**, avec 2 502 commandes alors que le mois n'est qu'à moitié passé. Le pic suit donc la date d'exécution : ce n'était pas une vraie hausse des ventes, mais un **effet de la génération des données**, qui produit plus de commandes près de la date du jour.

### 4. Une répartition des délais uniforme, sans livraisons très lentes

En comptant tout jour entamé (`CEIL`), les délais de transport se répartissent presque à égalité, environ **20 % chacun pour 1, 2, 3, 4 et 5 jours**. Aucune livraison ne dépasse 5 jours. Une vraie logistique montrerait plutôt une durée habituelle et une traîne de livraisons lentes : c'est une autre trace du caractère synthétique des données.

### 5. Les livraisons lentes par pays

Une livraison est considérée comme **lente au-delà de 4 jours de transport** (jour entamé compté), soit les 20 % de livraisons les plus longues.

| Rang | Pays | Délai moyen (jours) | Commandes livrées | Livraisons lentes |
| --- | --- | --- | --- | --- |
| 1 | Brasil | 2,50 | 6 434 | 19,66 % |
| 2 | United States | 2,49 | 9 735 | 19,63 % |
| 3 | Belgium | 2,56 | 596 | 19,46 % |
| … | … | … | … | … |
| 11 | United Kingdom | 2,44 | 2 106 | 17,85 % |

Le classement change selon l'indicateur : la Belgique a le délai moyen le plus long, mais ce sont le Brésil et les États-Unis qui ont la plus grande part de livraisons lentes. Les écarts restent cependant **inférieurs à 2 points**, trop faibles pour conclure qu'un pays est réellement plus lent.

## Conclusions

1. La boutique a multiplié son volume par 30 sans dégrader ses délais (environ 4 jours au total).
2. Le transport pèse environ 60 % de l'attente du client.
3. Les délais sont homogènes entre pays, que l'on regarde la moyenne ou la part de livraisons lentes.
4. Le pic de volume d'octobre 2026 était un effet de la génération des données, confirmé en refaisant l'analyse à une autre date.

## Limites

- Les données sont fictives et régénérées chaque jour : les résultats ne sont pas reproductibles à l'identique.
- Les données mesurent des délais, pas la qualité du service (colis abîmés, erreurs de commande).
- Aucune date de livraison promise n'est disponible : on parle de livraisons **lentes**, pas de **retards**.

## Ce que ce projet m'a appris

- Toujours afficher le volume à côté d'une moyenne, et exclure les échantillons trop petits.
- Vérifier un chiffre qui casse une tendance avant de le présenter comme un fait.
- Quand on change de méthode de calcul (`ROUND` contre `CEIL`), revérifier toutes les conclusions qui en dépendent.
- Distinguer ce que les données montrent de ce que l'on suppose.
