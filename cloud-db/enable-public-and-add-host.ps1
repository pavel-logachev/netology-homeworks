param([Parameter(Mandatory = $true)][string]$ClusterId)
$ErrorActionPreference = 'Stop'
$raw = & yc managed-postgresql cluster get $ClusterId --no-browser --format json
if ($LASTEXITCODE -ne 0) { throw 'Cannot verify cluster identity.' }
$cluster = $raw | ConvertFrom-Json
if ($cluster.name -ne 'nt-1209-pg' -or $cluster.folder_id -ne 'b1g6rd3uo8sajkqcmnbk' -or $cluster.status -ne 'RUNNING') {
    throw 'Expected homework cluster RUNNING in the designated folder.'
}
$raw = & yc managed-postgresql hosts list --cluster-id $ClusterId --no-browser --format json
if ($LASTEXITCODE -ne 0) { throw 'Cannot list hosts.' }
$hosts = @($raw | ConvertFrom-Json)
if ($hosts.Count -ne 1 -or $hosts[0].zone_id -ne 'ru-central1-d') { throw 'Expected one host in zone d.' }
& yc managed-postgresql hosts update $hosts[0].name --cluster-id $ClusterId --assign-public-ip --no-browser
if ($LASTEXITCODE -ne 0) { throw 'Public IP update failed; inspect and clean up.' }
& yc managed-postgresql hosts add --cluster-id $ClusterId --host 'zone-id=ru-central1-e,subnet-id=ajchab21lfk2jgqhhria,assign-public-ip=true' --no-browser --async --format yaml
if ($LASTEXITCODE -ne 0) { throw 'Second host addition failed; inspect and clean up.' }
