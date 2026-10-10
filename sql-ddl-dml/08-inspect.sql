-- Read-only live evidence after Task 1 setup and restore.
SELECT VERSION() AS mysql_version;
SELECT User, Host, plugin FROM mysql.user ORDER BY User, Host;
SHOW GRANTS FOR 'sys_temp'@'localhost'\G
SELECT USER() AS connected_as, CURRENT_USER() AS authenticated_as;
SELECT User, Host, plugin FROM mysql.user WHERE User = 'sys_temp';
USE sakila;
SHOW FULL TABLES;
SELECT TABLE_TYPE, COUNT(*) AS objects
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'sakila'
GROUP BY TABLE_TYPE ORDER BY TABLE_TYPE;
SELECT (SELECT COUNT(*) FROM customer) AS customers,
       (SELECT COUNT(*) FROM rental) AS rentals,
       (SELECT COUNT(*) FROM payment) AS payments;
