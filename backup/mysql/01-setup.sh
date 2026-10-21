#!/usr/bin/env bash
# Execute inside disposable nt-bkp-mysql; inherited MYSQL_ROOT_PASSWORD is not logged.
set -Eeuo pipefail
umask 077
mkdir -p /backups/incremental
printf '[client]\nuser=root\npassword=%s\n' "$MYSQL_ROOT_PASSWORD" > /root/source.cnf
printf '[client]\nuser=root\nhost=nt-bkp-mysql-restore\nprotocol=tcp\npassword=%s\n' "$MYSQL_ROOT_PASSWORD" > /root/target.cnf
set -x
mysql --version
mysqldump --version
mysqlbinlog --version
mysql --defaults-extra-file=/root/source.cnf -t <<'SQL'
SELECT @@hostname,@@version,@@server_id,@@log_bin,@@binlog_format,@@gtid_mode;
CREATE DATABASE demo;
USE demo;
CREATE TABLE customers(id INT PRIMARY KEY AUTO_INCREMENT, name VARCHAR(40) NOT NULL UNIQUE) ENGINE=InnoDB;
CREATE TABLE payments(id INT PRIMARY KEY AUTO_INCREMENT, customer_id INT NOT NULL, amount DECIMAL(12,2) NOT NULL CHECK(amount>0), FOREIGN KEY(customer_id) REFERENCES customers(id)) ENGINE=InnoDB;
INSERT INTO customers(name) VALUES('Pavel'),('Anna');
INSERT INTO payments(customer_id,amount) VALUES(1,1250.00),(2,750.50);
SELECT * FROM payments ORDER BY id;
SHOW BINARY LOGS;
SQL
mysql --defaults-extra-file=/root/target.cnf -t -e "SELECT @@hostname,@@version,@@server_id; SELECT count(*) AS demo_exists FROM information_schema.schemata WHERE schema_name='demo';"
