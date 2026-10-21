echo '=== Replica write must be rejected (including root) ==='
m replica -e 'SELECT @@server_id, @@read_only, @@super_read_only;'
sql replica /master-slave/sql/04-write-replica.sql
result=${PIPESTATUS[0]}
echo "mysql exit code=$result (expected nonzero)"
test "$result" -ne 0 || return 1
m replica -e 'SELECT COUNT(*) AS rows_after_rejected_write FROM replication_demo.messages;'
