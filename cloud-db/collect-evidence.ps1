param([Parameter(Mandatory = $true)][string]$ClusterId)
$ErrorActionPreference = 'Stop'
$utf8 = New-Object System.Text.UTF8Encoding($false)
$commands = @(
    @{ Name = '10-cluster.txt'; Args = @('cluster', 'get', $ClusterId) },
    @{ Name = '11-hosts.txt'; Args = @('hosts', 'list', '--cluster-id', $ClusterId) },
    @{ Name = '12-databases.txt'; Args = @('database', 'list', '--cluster-id', $ClusterId) },
    @{ Name = '13-users.txt'; Args = @('user', 'list', '--cluster-id', $ClusterId) }
)
foreach ($entry in $commands) {
    $ycArgs = @('managed-postgresql') + $entry.Args + @('--no-browser', '--format', 'yaml')
    $result = & yc @ycArgs
    if ($LASTEXITCODE -ne 0) { throw ('Evidence collection failed: ' + $entry.Name) }
    [System.IO.File]::WriteAllText((Join-Path $PSScriptRoot ('evidence/' + $entry.Name)), (($result -join "`n") + "`n"), $utf8)
}
