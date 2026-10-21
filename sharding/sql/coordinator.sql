\set ON_ERROR_STOP on
CREATE EXTENSION postgres_fdw;
CREATE ROLE app LOGIN;
CREATE SERVER users_a FOREIGN DATA WRAPPER postgres_fdw
    OPTIONS (host 'nt-shard-users-a', dbname 'shop');
CREATE SERVER users_b FOREIGN DATA WRAPPER postgres_fdw
    OPTIONS (host 'nt-shard-users-b', dbname 'shop');
CREATE SERVER catalog FOREIGN DATA WRAPPER postgres_fdw
    OPTIONS (host 'nt-shard-catalog', dbname 'shop');
-- TRUST is confined to this disposable lab. Remote identities are non-superusers.
CREATE USER MAPPING FOR app SERVER users_a
    OPTIONS (user 'shard_writer', password_required 'false');
CREATE USER MAPPING FOR app SERVER users_b
    OPTIONS (user 'shard_writer', password_required 'false');
CREATE USER MAPPING FOR app SERVER catalog
    OPTIONS (user 'catalog_writer', password_required 'false');
GRANT USAGE ON FOREIGN SERVER users_a, users_b, catalog TO app;
CREATE TABLE public.users (
    user_id bigint NOT NULL,
    full_name text NOT NULL,
    email text NOT NULL
) PARTITION BY RANGE (user_id);
CREATE FOREIGN TABLE public.users_a PARTITION OF public.users
    FOR VALUES FROM (1) TO (10000)
    SERVER users_a OPTIONS (schema_name 'public', table_name 'users');
CREATE FOREIGN TABLE public.users_b PARTITION OF public.users
    FOR VALUES FROM (10000) TO (MAXVALUE)
    SERVER users_b OPTIONS (schema_name 'public', table_name 'users');
CREATE FOREIGN TABLE public.stores (
    store_id bigint NOT NULL, name text NOT NULL, city text NOT NULL
) SERVER catalog OPTIONS (schema_name 'public', table_name 'stores');
CREATE FOREIGN TABLE public.books (
    book_id bigint NOT NULL, title text NOT NULL,
    store_id bigint NOT NULL, price numeric(10,2) NOT NULL
) SERVER catalog OPTIONS (schema_name 'public', table_name 'books');
GRANT SELECT, INSERT, UPDATE, DELETE ON public.users, public.stores, public.books TO app;
-- No physical user rows on coordinator; local PK unavailable on foreign partitions.
-- Per-shard PK + disjoint CHECK ranges guarantee user_id uniqueness across shards.
