\set ON_ERROR_STOP on
\pset pager off
\connect shop postgres nt-shard-replica-a
\echo '=== Replica A: hot standby, read-only, rows 1 / 42 / 9999 ==='
SELECT pg_is_in_recovery() AS recovery, current_setting('transaction_read_only') AS read_only;
SELECT user_id,full_name FROM users ORDER BY user_id;
SELECT status,slot_name FROM pg_stat_wal_receiver;
\connect shop postgres nt-shard-replica-b
\echo '=== Replica B: hot standby, read-only, rows 10000 / 10001 / 20000 ==='
SELECT pg_is_in_recovery() AS recovery, current_setting('transaction_read_only') AS read_only;
SELECT user_id,full_name FROM users ORDER BY user_id;
SELECT status,slot_name FROM pg_stat_wal_receiver;
\connect shop postgres nt-shard-users-a
SELECT application_name,state,sync_state FROM pg_stat_replication;
\connect shop postgres nt-shard-users-b
SELECT application_name,state,sync_state FROM pg_stat_replication;
