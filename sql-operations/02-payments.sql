-- Task 2: half-open interval includes all of 18 June 2005.
SELECT payment_id, customer_id, staff_id, rental_id, amount, payment_date
FROM payment
WHERE payment_date >= '2005-06-15 00:00:00'
  AND payment_date < '2005-06-19 00:00:00'
  AND amount > 10.00
ORDER BY payment_date, payment_id;
