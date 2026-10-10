-- Task 1.4-1.6: all global privileges, including grant option.
GRANT ALL PRIVILEGES ON *.* TO 'sys_temp'@'localhost' WITH GRANT OPTION;
SHOW GRANTS FOR 'sys_temp'@'localhost'\G
-- Course says sys_test by mistake: alter the account actually created.
ALTER USER 'sys_temp'@'localhost' IDENTIFIED WITH mysql_native_password
  BY 'NetologyTempLocal_2026';
SELECT User, Host, plugin FROM mysql.user WHERE User = 'sys_temp';
