echo '=== nt-repl-mm2 | copied my.cnf and effective runtime ==='
cat /etc/mysql/conf.d/master-master/mm2.cnf
m mm2 -e "SELECT @@hostname AS host, @@version AS version, @@server_id AS server_id;"
m mm2 -e "SELECT @@read_only AS read_only, @@super_read_only AS super_read_only;"
m mm2 -e "SELECT @@log_bin AS log_bin, @@binlog_format AS format, @@gtid_mode AS gtid, @@enforce_gtid_consistency AS consistency;"
