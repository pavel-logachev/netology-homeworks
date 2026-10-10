-- Task 1.6-1.8: run this client script while connected as sys_temp.
-- Official Sakila 1.5 archive extracted under /tmp/sakila-db.
SELECT USER() AS connected_as, CURRENT_USER() AS authenticated_as;
SOURCE /tmp/sakila-db/sakila-schema.sql;
SOURCE /tmp/sakila-db/sakila-data.sql;
USE sakila;
SHOW FULL TABLES;
SELECT TABLE_TYPE, COUNT(*) AS objects
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'sakila'
GROUP BY TABLE_TYPE ORDER BY TABLE_TYPE;
SELECT (SELECT COUNT(*) FROM customer) AS customers,
       (SELECT COUNT(*) FROM rental) AS rentals,
       (SELECT COUNT(*) FROM payment) AS payments;
