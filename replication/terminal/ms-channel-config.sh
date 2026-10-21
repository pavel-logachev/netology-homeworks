echo '=== Executed setup SQL (saved inputs); privilege verification ==='
cat /master-slave/sql/01-user.sql /master-slave/sql/02-replica.sql
m master -e "SHOW GRANTS FOR 'repl'@'%';"
echo '=== Current replication channel ==='
status replica
