# Explicitly authorized disposable objects, not a generic prune.
$ErrorActionPreference = 'Continue'
$log = Join-Path (Get-Location) 'evidence\cleanup.txt'
$enc = New-Object System.Text.UTF8Encoding $false
[IO.File]::WriteAllText($log, ('Cleanup UTC ' + (Get-Date).ToUniversalTime().ToString('o') + "`n"), $enc)
function Log-Command([string[]]$DockerArgs) {
    $out = & docker @DockerArgs 2>&1
    $code = $LASTEXITCODE
    $text = 'docker ' + ($DockerArgs -join ' ') + "`n" + ($out | Out-String) + "[exit code: $code]`n"
    [IO.File]::AppendAllText($log, $text, $enc)
    Write-Output $text
    if ($code -ne 0) { throw 'Cleanup command failed' }
}
# Exact targets inspected immediately before deletion.
Log-Command @('inspect','--format','{{.Name}} {{.Image}}','nt1303-defender','nt1303-attacker')
Log-Command @('network','inspect','--format','{{.Name}} {{.Internal}}','nt1303-isolated')
Log-Command @('compose','-f','stand/compose.yaml','down')
Log-Command @('image','rm','nt1303-lab:noble')
# No hardcoded historical image ID: deleting the tag can also remove its underlying image.
# The original run attempted the old ID afterwards and got No such image; see cleanup.txt.
Log-Command @('ps','-a','--filter','name=nt1303-')
Log-Command @('network','ls','--filter','name=nt1303-')
$containers = @(docker ps -a --filter name=nt1303- --format '{{.Names}}')
$networks = @(docker network ls --filter name=nt1303- --format '{{.Name}}')
$images = @(docker images --filter reference=nt1303-* --format '{{.Repository}}:{{.Tag}}')
$text = "containers_count=$($containers.Count)`nnetworks_count=$($networks.Count)`nimages_count=$($images.Count)`n"
[IO.File]::AppendAllText($log, $text, $enc)
Write-Output $text
if ($containers.Count -or $networks.Count -or $images.Count) { throw 'Owned resources remain' }
