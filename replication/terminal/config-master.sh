echo '=== nt-repl-master | copied my.cnf and effective runtime ==='
cat /etc/mysql/conf.d/master-slave/master.cnf
m master -e "SELECT @@hostname AS host, @@version AS version, @@server_id AS server_id;"
m master -e "SELECT @@read_only AS read_only, @@super_read_only AS super_read_only;"
m master -e "SELECT @@log_bin AS log_bin, @@binlog_format AS format, @@gtid_mode AS gtid, @@enforce_gtid_consistency AS consistency;"
