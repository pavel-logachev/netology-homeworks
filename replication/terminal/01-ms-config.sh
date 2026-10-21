echo '=== MASTER / copied effective configuration ==='
cat /master-slave/conf/master.cnf
m master -e "SELECT @@hostname, @@version, @@server_id, @@read_only, @@super_read_only;"
echo '=== REPLICA / copied effective configuration ==='
cat /master-slave/conf/replica.cnf
m replica -e "SELECT @@hostname, @@server_id, @@read_only, @@super_read_only;"
