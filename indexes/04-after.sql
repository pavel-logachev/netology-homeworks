EXPLAIN ANALYZE
SELECT DISTINCT CONCAT(c.last_name, ' ', c.first_name) AS customer_name,
       SUM(p.amount) AS total_amount
FROM payment AS p
JOIN rental AS r ON r.rental_date = p.payment_date
JOIN customer AS c ON c.customer_id = r.customer_id
WHERE p.payment_date >= '2005-07-30' AND p.payment_date < '2005-07-31'
GROUP BY c.customer_id, c.last_name, c.first_name\G
