echo '=== nt-repl-mm1 | writable + interleaved AUTO_INCREMENT ==='
m mm1 -e "SELECT @@server_id AS id, @@read_only AS ro, @@super_read_only AS sro, @@auto_increment_increment AS step, @@auto_increment_offset AS offset;"
m mm1 -e 'SELECT * FROM circular_demo.messages ORDER BY id;'
echo '=== SHOW REPLICA STATUS\G | relevant fields ==='
status mm1
