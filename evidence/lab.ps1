$ErrorActionPreference = 'Stop'
$Root='C:\Users\pavel\Documents\DeepSeekHarness\cache\netology-20261107\w-1301'
$Evidence="$Root\wt\evidence"
function D {
 param([string[]]$A,[string]$Log='commands.txt',[switch]$AllowFailure)
 $line='docker ' + (($A | ForEach-Object { if ($_ -match '[\s";]') { "'" + $_.Replace("'","''") + "'" } else { $_ } }) -join ' ')
 $stamp=Get-Date -Format o
 [IO.File]::AppendAllText("$Evidence\commands.txt", "`n[$stamp] $line`n", (New-Object Text.UTF8Encoding $false))
 $ErrorActionPreference='Continue'
 $result=& docker @A 2>&1
 $code=$LASTEXITCODE
 $ErrorActionPreference='Stop'
 $text=($result | Out-String)
 [IO.File]::AppendAllText("$Evidence\$Log", $text, (New-Object Text.UTF8Encoding $false))
 if ($Log -ne 'commands.txt') { [IO.File]::AppendAllText("$Evidence\commands.txt", $text, (New-Object Text.UTF8Encoding $false)) }
 [IO.File]::AppendAllText("$Evidence\commands.txt", "exit=$code`n", (New-Object Text.UTF8Encoding $false))
 $result | ForEach-Object { Write-Host $_ }
 if ($code -ne 0 -and -not $AllowFailure) { throw "Docker exit $code for $line" }
}
