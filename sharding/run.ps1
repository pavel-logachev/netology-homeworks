# Windows PowerShell 5.1. Run from any directory; leaves stand running for inspection.
$ErrorActionPreference = 'Stop'
Push-Location $PSScriptRoot
try {
    docker compose config --quiet
    if ($LASTEXITCODE -ne 0) { throw 'Invalid Compose configuration' }
    docker compose up -d --wait --wait-timeout 180
    if ($LASTEXITCODE -ne 0) { throw 'Stand startup failed; inspect docker compose logs' }
    docker compose exec -T nt-shard-client psql -X -a -h nt-shard-coordinator -f /lab/demo.sql
    if ($LASTEXITCODE -ne 0) { throw 'SQL demo failed' }
    docker compose exec -T nt-shard-client bash /lab/scripts/check.sh
    if ($LASTEXITCODE -ne 0) { throw 'Sharding/replication checks failed' }
    docker compose exec -T nt-shard-client psql -X -a -h nt-shard-coordinator -f /lab/sql/replicas.sql
    if ($LASTEXITCODE -ne 0) { throw 'Replica inspection failed' }
    docker compose ps
    if ($LASTEXITCODE -ne 0) { throw 'docker compose ps failed' }
} finally {
    Pop-Location
}
# Explicit requested cleanup (destructive: deletes this lab's database volumes):
# docker compose -f "$PSScriptRoot/docker-compose.yml" down --volumes
