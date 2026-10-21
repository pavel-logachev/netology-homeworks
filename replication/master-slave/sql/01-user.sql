-- Disposable lab credential, not a production secret. Do not binlog local accounts.
SET SESSION sql_log_bin=0;
CREATE USER 'repl'@'%' IDENTIFIED BY 'nt-repl-only';
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';
SET SESSION sql_log_bin=1;
SHOW GRANTS FOR 'repl'@'%';
