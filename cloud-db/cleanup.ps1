param(
    [string]$FolderId = 'b1g6rd3uo8sajkqcmnbk',
    [string]$ClusterName = 'nt-1209-pg'
)
$ErrorActionPreference = 'Stop'
# Only the explicitly named homework cluster may be deleted.
if ($ClusterName -ne 'nt-1209-pg') { throw 'Unexpected cluster name.' }
$raw = & yc managed-postgresql cluster list --folder-id $FolderId --no-browser --format json
if ($LASTEXITCODE -ne 0) { throw 'Cannot verify cluster ownership.' }
$clusters = $raw | ConvertFrom-Json
$target = @($clusters | Where-Object { $_.name -eq $ClusterName })
if ($target.Count -gt 1) { throw 'Ambiguous cluster ownership.' }
if ($target.Count -eq 1) {
    & yc managed-postgresql cluster delete --id $target[0].id --folder-id $FolderId --no-browser --async
    if ($LASTEXITCODE -ne 0) { throw 'Cluster deletion request failed.' }
    $deadline = (Get-Date).AddMinutes(20)
    do {
        $raw = & yc managed-postgresql cluster list --folder-id $FolderId --no-browser --format json
        if ($LASTEXITCODE -ne 0) { throw 'Deletion verification failed.' }
        $remaining = @($raw | ConvertFrom-Json | Where-Object { $_.name -eq $ClusterName })
        if ($remaining.Count -eq 0) { break }
        if ((Get-Date) -gt $deadline) { throw 'Deletion timed out: inspect cluster before leaving.' }
        Start-Sleep -Seconds 15
    } while ($true)
}
$raw | Set-Content -Encoding utf8 (Join-Path $PSScriptRoot 'evidence/90-cluster-list-after.txt')
# This run used the unchanged default SG; no SG was created and none must be deleted.
$names = & docker ps -a --filter name=nt-1209- --format '{{.Names}}'
if ($LASTEXITCODE -ne 0) { throw 'Cannot list helper containers.' }
foreach ($name in $names) {
    if ($name -match '^nt-1209-[a-z0-9-]+$') {
        & docker rm -f -v $name
        if ($LASTEXITCODE -ne 0) { throw 'Helper cleanup failed.' }
    }
}
$volumes = & docker volume ls --filter name=nt-1209- --format '{{.Name}}'
if ($LASTEXITCODE -ne 0) { throw 'Cannot list helper volumes.' }
foreach ($volume in $volumes) {
    if ($volume -match '^nt-1209-[a-z0-9-]+$') {
        & docker volume rm $volume
        if ($LASTEXITCODE -ne 0) { throw 'Helper volume cleanup failed.' }
    }
}
$raw
