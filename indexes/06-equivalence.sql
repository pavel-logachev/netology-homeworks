-- Root session: temporary tables only; base data is unchanged.
CREATE TEMPORARY TABLE original_result AS
SELECT DISTINCT CONCAT(c.last_name, ' ', c.first_name) AS customer_name,
       SUM(p.amount) OVER (PARTITION BY c.customer_id, f.title) AS total_amount
FROM payment p, rental r, customer c, inventory i, film f
WHERE DATE(p.payment_date) = '2005-07-30'
  AND p.payment_date = r.rental_date
  AND r.customer_id = c.customer_id AND i.inventory_id = r.inventory_id;
CREATE TEMPORARY TABLE optimized_result AS
SELECT DISTINCT CONCAT(c.last_name, ' ', c.first_name) AS customer_name,
       SUM(p.amount) AS total_amount
FROM payment AS p
JOIN rental AS r ON r.rental_date = p.payment_date
JOIN customer AS c ON c.customer_id = r.customer_id
WHERE p.payment_date >= '2005-07-30' AND p.payment_date < '2005-07-31'
GROUP BY c.customer_id, c.last_name, c.first_name;
SELECT (SELECT COUNT(*) FROM original_result) AS original_rows,
       (SELECT COUNT(*) FROM optimized_result) AS optimized_rows;
SELECT COUNT(*) AS original_minus_optimized
FROM original_result a LEFT JOIN optimized_result b
 ON a.customer_name = b.customer_name AND a.total_amount = b.total_amount
WHERE b.customer_name IS NULL;
SELECT COUNT(*) AS optimized_minus_original
FROM optimized_result b LEFT JOIN original_result a
 ON a.customer_name = b.customer_name AND a.total_amount = b.total_amount
WHERE a.customer_name IS NULL;
SELECT COUNT(*) AS film_rows, COUNT(DISTINCT title) AS distinct_titles FROM film;
SELECT COUNT(*) AS timestamp_join_rows, COUNT(DISTINCT p.payment_id) AS payments,
       SUM(r.rental_id <> p.rental_id) AS different_rental_id
FROM payment p JOIN rental r ON r.rental_date = p.payment_date
WHERE p.payment_date >= '2005-07-30' AND p.payment_date < '2005-07-31';
