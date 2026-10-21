\set ON_ERROR_STOP on
\pset pager off
\connect shop app nt-shard-coordinator
\echo '=== Coordinator: real INSERT routing (including boundary keys) ==='
-- Repeatable demo; delete only this fixture, not arbitrary stand data.
DELETE FROM users WHERE user_id IN (1,42,9999,10000,10001,20000);
INSERT INTO users (user_id, full_name, email) VALUES
 (1,'Pavel Logachev','pavel@example.test'),
 (42,'Anna','anna@example.test'),
 (9999,'Lower boundary','lower@example.test'),
 (10000,'Upper boundary','upper@example.test'),
 (10001,'Boris','boris@example.test'),
 (20000,'Vera','vera@example.test');
SELECT tableoid::regclass AS routed_partition, user_id, full_name FROM users ORDER BY user_id;
\echo '=== Vertical domain: books and stores written through FDW ==='
DELETE FROM books WHERE book_id IN (101,102);
DELETE FROM stores WHERE store_id IN (10,20);
INSERT INTO stores VALUES (10,'Central','Moscow'),(20,'North','Saint Petersburg');
INSERT INTO books VALUES (101,'PostgreSQL Basics',10,990.00),(102,'Distributed Systems',20,1490.00);
SELECT b.book_id,b.title,s.name AS store,s.city FROM books b JOIN stores s USING(store_id) ORDER BY book_id;
\echo '=== Partition pruning: only users_b for user_id=10000 ==='
EXPLAIN (COSTS OFF) SELECT * FROM users WHERE user_id=10000;
\connect shop postgres nt-shard-users-a
\echo '=== Direct shard A: [1,10000); primary read-write ==='
SELECT pg_is_in_recovery() AS recovery, current_setting('transaction_read_only') AS read_only;
TABLE users;
\connect shop postgres nt-shard-users-b
\echo '=== Direct shard B: [10000,+infinity); primary read-write ==='
SELECT pg_is_in_recovery() AS recovery, current_setting('transaction_read_only') AS read_only;
TABLE users;
\connect shop postgres nt-shard-catalog
\echo '=== Direct catalog: physical tables and local FK ==='
SELECT tablename FROM pg_tables WHERE schemaname='public' ORDER BY tablename;
SELECT b.book_id,b.title,s.name FROM books b JOIN stores s USING(store_id) ORDER BY book_id;
