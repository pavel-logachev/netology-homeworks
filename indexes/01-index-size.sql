ANALYZE TABLE actor, address, category, city, country, customer, film,
  film_actor, film_category, film_text, inventory, language, payment,
  rental, staff, store;
SELECT TABLE_SCHEMA AS schema_name, COUNT(*) AS base_tables,
       SUM(DATA_LENGTH) AS data_bytes, SUM(INDEX_LENGTH) AS index_bytes,
       SUM(DATA_LENGTH + INDEX_LENGTH) AS data_plus_indexes_bytes,
       ROUND(100.0 * SUM(INDEX_LENGTH) / NULLIF(SUM(DATA_LENGTH), 0), 2)
         AS index_to_data_percent
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'sakila' AND TABLE_TYPE = 'BASE TABLE'
GROUP BY TABLE_SCHEMA;
