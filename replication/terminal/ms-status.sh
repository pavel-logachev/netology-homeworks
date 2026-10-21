echo '=== master binlog ==='
m master -e 'SHOW MASTER STATUS\G'
echo '=== SHOW REPLICA STATUS\G | relevant fields ==='
status replica
