SELECT VERSION() AS mysql_version, DATABASE() AS db,
       CURRENT_USER() AS authenticated_as;
SELECT TABLE_NAME, ENGINE FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'sakila' AND TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;
SELECT SUM(DATA_LENGTH) AS data_bytes, SUM(INDEX_LENGTH) AS index_bytes,
       ROUND(100.0 * SUM(INDEX_LENGTH) / NULLIF(SUM(DATA_LENGTH), 0), 2)
         AS index_to_data_percent_after_index
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'sakila' AND TABLE_TYPE = 'BASE TABLE';
SELECT (SELECT COUNT(*) FROM payment) AS payments,
       (SELECT COUNT(*) FROM rental) AS rentals,
       (SELECT COUNT(*) FROM film) AS films,
       (SELECT COUNT(*) FROM customer) AS customers;
