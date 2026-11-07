param(
    [string]$FolderId = 'b1g6rd3uo8sajkqcmnbk',
    [string]$NetworkId = 'enporko3shdet3dcnj6p',
    [string]$Zone1 = 'ru-central1-a',
    [string]$Zone2 = 'ru-central1-d',
    [string]$Subnet1 = 'e9bd7l4u3g5amt2nutgv',
    [string]$Subnet2 = 'fl8nn5pcgd6tt6p3mo38',
    [string]$SecurityGroupId = 'enp7kjlh514qff7lh4mo',
    [string]$ClusterName = 'nt-1209-pg',
    [string]$ResourcePreset = 's3-c2-m8'
)
$ErrorActionPreference = 'Stop'
if (-not $env:NT1209_PG_PASSWORD) { throw 'Set NT1209_PG_PASSWORD outside the repository first.' }
if ($ClusterName -notlike 'nt-1209-*') { throw 'Only homework-prefixed resources are permitted.' }
# REST keeps the database password and IAM token out of process arguments.
# API reference: https://yandex.cloud/en/docs/managed-postgresql/api-ref/Cluster/create
$tokenRaw = & yc iam create-token --no-browser --format json
if ($LASTEXITCODE -ne 0) { throw 'IAM token acquisition failed.' }
$token = ($tokenRaw | ConvertFrom-Json).iam_token
if (-not $token -or $token -match '[\r\n]') { throw 'Invalid IAM token response.' }
$body = @{
    folderId = $FolderId; name = $ClusterName; environment = 'PRODUCTION'; networkId = $NetworkId
    configSpec = @{ version = '16'; resources = @{ resourcePresetId = $ResourcePreset; diskSize = '10737418240'; diskTypeId = 'network-ssd' } }
    databaseSpecs = @(@{ name = 'nt-1209-db'; owner = 'nt-1209-user' })
    userSpecs = @(@{ name = 'nt-1209-user'; password = $env:NT1209_PG_PASSWORD })
    hostSpecs = @(
        @{ zoneId = $Zone1; subnetId = $Subnet1; assignPublicIp = $true },
        @{ zoneId = $Zone2; subnetId = $Subnet2; assignPublicIp = $true }
    )
    securityGroupIds = @($SecurityGroupId); deletionProtection = $false
}
try {
    $result = Invoke-RestMethod -Method Post -Uri 'https://mdb.api.cloud.yandex.net/managed-postgresql/v1/clusters' -Headers @{ Authorization = ('Bearer ' + $token) } -ContentType 'application/json' -Body ($body | ConvertTo-Json -Depth 12 -Compress) -TimeoutSec 90
    $evidence = Join-Path $PSScriptRoot 'evidence'
    New-Item -ItemType Directory -Force $evidence | Out-Null
    $text = $result | ConvertTo-Json -Depth 30
    [IO.File]::WriteAllText((Join-Path $evidence '00-create-operation.json'), ($text + "`n"), (New-Object Text.UTF8Encoding $false))
    $text
} finally {
    $token = $null; $tokenRaw = $null; $body = $null
}
