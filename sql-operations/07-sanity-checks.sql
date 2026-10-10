-- Counts and comparison used in the internal results notes.
SELECT COUNT(DISTINCT district) AS task1_rows FROM address
WHERE district COLLATE utf8mb4_bin LIKE 'K%a' AND district NOT LIKE '% %';
SELECT DISTINCT district AS plain_like_district FROM address
WHERE district LIKE 'K%a' AND district NOT LIKE '% %' ORDER BY district;
SELECT COUNT(*) AS task2_rows FROM payment
WHERE payment_date >= '2005-06-15' AND payment_date < '2005-06-19'
  AND amount > 10.00;
SELECT COUNT(*) AS task3_rows FROM
 (SELECT rental_id FROM rental ORDER BY rental_date DESC, rental_id DESC LIMIT 5) AS r;
SELECT COUNT(*) AS task4_rows FROM customer
WHERE active = 1 AND first_name IN ('Kelly', 'Willie');
SELECT COUNT(*) AS task5_rows, COUNT(*) AS task6_rows,
       SUM(email IS NULL) AS null_emails,
       SUM(LENGTH(email) - LENGTH(REPLACE(email, '@', '')) <> 1) AS invalid_at_count
FROM customer;
SELECT character_set_name, collation_name FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = 'sakila' AND TABLE_NAME = 'address' AND COLUMN_NAME = 'district';
