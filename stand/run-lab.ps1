# Run from worktree root after docker compose up and prepare-suricata.py.
# Only the two owned containers and fixed owned IPs are used.
$ErrorActionPreference = 'Continue'
$enc = New-Object System.Text.UTF8Encoding $false
function Run-LabCommand([string]$Name, [string[]]$DockerArgs, [int[]]$Allowed = @(0)) {
    $line = 'docker ' + ($DockerArgs -join ' ')
    [IO.File]::AppendAllText((Join-Path (Get-Location) 'evidence\commands.txt'), "`n$line`n", $enc)
    $result = & docker @DockerArgs 2>&1
    $code = $LASTEXITCODE
    $text = ($result | Out-String) + "[exit code: $code]`n"
    [IO.File]::WriteAllText((Join-Path (Get-Location) ('evidence\' + $Name + '.txt')), $line + "`n" + $text, $enc)
    Write-Output ($Name + ': exit=' + $code)
    Write-Output $text
    if ($Allowed -notcontains $code) { throw ('Failed: ' + $Name) }
}
function Checkpoint([string]$Phase) {
    Run-LabCommand ($Phase + '-checkpoint') @('exec','nt1303-defender','python3','/lab/checkpoint.py',$Phase)
}
Run-LabCommand 'suricata-prepare' @('exec','nt1303-defender','python3','/lab/prepare-suricata.py')
Run-LabCommand 'suricata-test' @('exec','nt1303-defender','suricata','-T','-c','/etc/suricata/suricata.yaml')
Run-LabCommand 'suricata-start' @('exec','nt1303-defender','python3','/lab/start-suricata.py')
Run-LabCommand 'enable-for-scans' @('exec','nt1303-defender','bash','-c',"sed -i 's/enabled = false/enabled = true/' /etc/fail2ban/jail.local; fail2ban-client reload; fail2ban-client status sshd")
Checkpoint 'baseline'
foreach ($mode in @('sA','sT','sS','sV')) {
    Run-LabCommand ('nmap-' + $mode) @('exec','nt1303-attacker','timeout','90','nmap',('-' + $mode),'172.30.133.10')
    Start-Sleep -Seconds 4
    Run-LabCommand ('nmap-' + $mode + '-jail-status') @('exec','nt1303-defender','fail2ban-client','status','sshd')
    Checkpoint ('nmap-' + $mode)
}
Run-LabCommand 'disable-before-hydra' @('exec','nt1303-defender','bash','-c',"sed -i 's/enabled = true/enabled = false/' /etc/fail2ban/jail.local; fail2ban-client reload; fail2ban-client status")
Checkpoint 'before-hydra-disabled'
Run-LabCommand 'hydra-disabled' @('exec','-w','/lab','nt1303-attacker','timeout','120','hydra','-I','-L','users.txt','-P','pass.txt','-t','1','-W','1','-f','-V','172.30.133.10','ssh')
Start-Sleep -Seconds 4
Checkpoint 'hydra-disabled'
# With jail disabled, old failures must not trigger the enabled phase.
# Start a fresh jail from the current end of auth.log using an explicit tail logpath.
Run-LabCommand 'enable-before-hydra' @('exec','nt1303-defender','bash','-c',"sed -i 's/enabled = false/enabled = true/; s|logpath = /var/log/auth.log|logpath = /var/log/auth.log tail|' /etc/fail2ban/jail.local; fail2ban-client reload; fail2ban-client status sshd")
Checkpoint 'before-hydra-enabled'
Run-LabCommand 'hydra-enabled' @('exec','-w','/lab','nt1303-attacker','timeout','100','hydra','-I','-L','users.txt','-P','pass.txt','-t','1','-W','1','-w','5','-f','-V','172.30.133.10','ssh') @(0,1,124,255)
Start-Sleep -Seconds 4
Run-LabCommand 'fail2ban-status-banned' @('exec','nt1303-defender','fail2ban-client','status','sshd')
Run-LabCommand 'firewall-banned' @('exec','nt1303-defender','bash','-c','iptables -S; iptables -L -n -v; nft list ruleset')
Run-LabCommand 'hydra-post-ban' @('exec','-w','/lab','nt1303-attacker','timeout','20','hydra','-I','-l','labuser','-p','LabOnly-1303-Throwaway!','-t','1','-w','5','172.30.133.10','ssh') @(0,1,124,255)
Start-Sleep -Seconds 3
Checkpoint 'hydra-enabled'
Run-LabCommand 'stop-suricata' @('exec','nt1303-defender','bash','-c','kill -INT $(cat /var/run/suricata.pid); sleep 3')
Checkpoint 'final'
Run-LabCommand 'rules-metadata' @('exec','nt1303-defender','bash','-c',"wc -l /var/lib/suricata/rules/suricata.rules; sha256sum /var/lib/suricata/rules/*.rules; grep -E 'ET SCAN.*(SSH|Nmap|Potential SSH)' /var/lib/suricata/rules/suricata.rules | head -15")
Run-LabCommand 'copy-phase-evidence' @('cp','nt1303-defender:/evidence/.','evidence/')
Run-LabCommand 'copy-suricata-full' @('cp','nt1303-defender:/var/log/suricata/.','evidence/suricata-full/')
Run-LabCommand 'copy-auth-full' @('cp','nt1303-defender:/var/log/auth.log','evidence/auth-full.log')
Run-LabCommand 'copy-fail2ban-full' @('cp','nt1303-defender:/var/log/fail2ban.log','evidence/fail2ban-full.log')
Run-LabCommand 'copy-suricata-config' @('cp','nt1303-defender:/etc/suricata/suricata.yaml','stand/suricata.observed.yaml')
Run-LabCommand 'copy-enabled-jail' @('cp','nt1303-defender:/etc/fail2ban/jail.local','stand/jail-enabled.observed.local')
