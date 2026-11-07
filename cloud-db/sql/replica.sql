\set ON_ERROR_STOP on
\pset pager off
\conninfo
select case when pg_is_in_recovery() then 'REPLICA' else 'MASTER' end;
select status from pg_stat_wal_receiver;
select * from test_table;
\q
