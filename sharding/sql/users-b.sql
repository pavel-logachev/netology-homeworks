\set ON_ERROR_STOP on
-- Physical shard: remote constraints protect direct writes as well as FDW writes.
CREATE ROLE shard_writer LOGIN;
CREATE ROLE replicator LOGIN REPLICATION;
CREATE TABLE public.users (
    user_id bigint PRIMARY KEY,
    full_name text NOT NULL,
    email text NOT NULL,
    CONSTRAINT users_range CHECK (user_id >= 10000)
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.users TO shard_writer;
