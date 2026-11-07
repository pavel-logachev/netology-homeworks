\set ON_ERROR_STOP on
\pset pager off
\conninfo
select version();
select case when pg_is_in_recovery() then 'REPLICA' else 'MASTER' end;
select count(*) from pg_stat_replication;
CREATE TABLE test_table(text varchar);
insert into test_table values('Строка 1'), ('Строка 2');
select * from test_table;
\q
