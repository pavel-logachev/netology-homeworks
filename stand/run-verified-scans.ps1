# Run only after verified-scans.py prints READY_FOR_SCANS.
$ErrorActionPreference = 'Stop'
$enc = New-Object System.Text.UTF8Encoding $false
foreach ($mode in @('sA','sT','sS','sV')) {
    $cmd = 'docker exec nt1303-attacker timeout 90 nmap -' + $mode + ' 172.30.133.10'
    [IO.File]::AppendAllText((Join-Path (Get-Location) 'evidence\commands.txt'), "`n$cmd`n", $enc)
    $out = & docker exec nt1303-attacker timeout 90 nmap ('-' + $mode) 172.30.133.10
    $code = $LASTEXITCODE
    [IO.File]::WriteAllText((Join-Path (Get-Location) ('evidence\verified-nmap-' + $mode + '.txt')), $cmd + "`n" + ($out -join "`n") + "`n[exit code: $code]`n", $enc)
    if ($code -ne 0) { throw 'Scan failed' }
    # Bounded output flush interval, distinct from readiness check.
    Start-Sleep -Seconds 5
    $status = docker exec nt1303-defender fail2ban-client status sshd
    [IO.File]::WriteAllText((Join-Path (Get-Location) ('evidence\verified-nmap-' + $mode + '-jail-status.txt')), ($status -join "`n") + "`n", $enc)
    $delta = docker exec nt1303-defender python3 /lab/checkpoint.py ('verified-nmap-' + $mode)
    [IO.File]::WriteAllText((Join-Path (Get-Location) ('evidence\verified-nmap-' + $mode + '-checkpoint.txt')), ($delta -join "`n") + "`n", $enc)
    Write-Output $out
    Write-Output $delta
}
docker exec nt1303-defender bash -c 'kill -INT $(cat /var/run/suricata.pid); sleep 3'
docker exec nt1303-defender python3 /lab/checkpoint.py verified-scans-final | Out-File -Encoding utf8 evidence\verified-scans-final-checkpoint.txt
docker cp nt1303-defender:/evidence/. evidence/
docker cp nt1303-defender:/var/log/suricata/. evidence/suricata-full/
docker cp nt1303-defender:/var/log/auth.log evidence/auth-full.log
docker cp nt1303-defender:/var/log/fail2ban.log evidence/fail2ban-full.log
