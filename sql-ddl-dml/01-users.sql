-- Task 1.1-1.3: clean MySQL 8.0 and the new local account.
SELECT VERSION() AS mysql_version;
CREATE USER 'sys_temp'@'localhost' IDENTIFIED BY 'NetologyTempLocal_2026';
SELECT User, Host, plugin FROM mysql.user ORDER BY User, Host;
