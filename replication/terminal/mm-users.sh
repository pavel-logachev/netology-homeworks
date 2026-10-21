echo '=== Account setup executed locally on both nodes (not binlogged) ==='
cat /master-master/sql/01-user.sql
echo '=== Grants on mm1 ==='
m mm1 -e "SHOW GRANTS FOR 'repl'@'%';"
echo '=== Grants on mm2 ==='
m mm2 -e "SHOW GRANTS FOR 'repl'@'%';"
