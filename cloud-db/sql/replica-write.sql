\set ON_ERROR_STOP on
\pset pager off
show transaction_read_only;
insert into test_table values('replica write must fail');
