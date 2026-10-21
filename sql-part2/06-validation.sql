SELECT store_id, COUNT(*) AS customers FROM customer GROUP BY store_id;
SELECT DATE_FORMAT(payment_date, '%Y-%m') AS month, SUM(amount) AS amount,
       COUNT(*) AS payments FROM payment GROUP BY month ORDER BY amount DESC;
SELECT staff_id, COUNT(*) AS rentals FROM rental GROUP BY staff_id;
SELECT COUNT(*) AS never_rented,
       SUM(NOT EXISTS (SELECT 1 FROM inventory i WHERE i.film_id=f.film_id)) AS without_inventory
FROM film f WHERE NOT EXISTS (
 SELECT 1 FROM inventory i JOIN rental r ON r.inventory_id=i.inventory_id
 WHERE i.film_id=f.film_id);
