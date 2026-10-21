#!/usr/bin/env bash
set -euo pipefail
export PGUSER=postgres PGDATABASE=shop
assert_query() {
  local host=$1 sql=$2 expected=$3
  local actual
  actual=$(psql -XAt -h "$host" -v ON_ERROR_STOP=1 -c "$sql")
  [ "$actual" = "$expected" ] || { echo "FAIL: $host expected=$expected actual=$actual"; exit 1; }
  echo "PASS: $host => $actual"
}
expect_error() {
  local host=$1 user=$2 sql=$3 state=$4
  local output
  if output=$(psql -X -h "$host" -U "$user" -v ON_ERROR_STOP=1 -v VERBOSITY=verbose -c "$sql" 2>&1); then
    echo 'FAIL: expected SQL error'; exit 1
  fi
  printf '%s\n' "$output"
  [[ "$output" == *"$state"* ]] || { echo "FAIL: expected SQLSTATE $state"; exit 1; }
  echo "PASS: expected SQLSTATE $state"
}
bash /lab/scripts/wait-replicas.sh
assert_query nt-shard-users-a 'SELECT string_agg(user_id::text,chr(44) ORDER BY user_id) FROM users' '1,42,9999'
assert_query nt-shard-users-b 'SELECT string_agg(user_id::text,chr(44) ORDER BY user_id) FROM users' '10000,10001,20000'
assert_query nt-shard-replica-a 'SELECT count(*)=3 AND bool_and(user_id<10000) FROM users' t
assert_query nt-shard-replica-b 'SELECT count(*)=3 AND bool_and(user_id>=10000) FROM users' t
assert_query nt-shard-catalog "SELECT count(*) FROM pg_tables WHERE schemaname='public' AND tablename IN ('books','stores')" 2
assert_query nt-shard-users-a "SELECT count(*) FROM pg_tables WHERE schemaname='public' AND tablename IN ('books','stores')" 0
assert_query nt-shard-users-b "SELECT count(*) FROM pg_tables WHERE schemaname='public' AND tablename IN ('books','stores')" 0
assert_query nt-shard-coordinator "SELECT count(*) FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='public' AND c.relkind='r'" 0
expect_error nt-shard-coordinator app "INSERT INTO users VALUES (0,'Invalid','invalid@example.test')" 23514
expect_error nt-shard-coordinator app "INSERT INTO users VALUES (1,'Duplicate','dup@example.test')" 23505
expect_error nt-shard-users-a shard_writer "INSERT INTO users VALUES (10000,'Wrong shard','wrong@example.test')" 23514
expect_error nt-shard-users-b shard_writer "INSERT INTO users VALUES (9999,'Wrong shard','wrong@example.test')" 23514
expect_error nt-shard-catalog catalog_writer "INSERT INTO books VALUES (999,'Missing store',999,1.00)" 23503
for key in a b; do
 expect_error "nt-shard-replica-$key" postgres "INSERT INTO users VALUES (123,'Forbidden','no@example.test')" 25006
 assert_query "nt-shard-replica-$key" "SELECT pg_is_in_recovery() AND current_setting('transaction_read_only')='on'" t
 assert_query "nt-shard-users-$key" "SELECT count(*) FROM pg_stat_replication WHERE state='streaming' AND sync_state='async'" 1
done
echo 'ALL CHECKS PASSED'
