echo '=== Executed master SQL (saved input) ==='
cat /master-slave/sql/03-write-master.sql
echo '=== Read master and wait for its GTID on replica ==='
m master -e 'SELECT * FROM replication_demo.messages ORDER BY id;'
wait_for master replica
m replica -e 'SELECT * FROM replication_demo.messages ORDER BY id;'
