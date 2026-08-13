[CmdletBinding()]
param(
    [string]$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..\..')).Path
)

$ErrorActionPreference = 'Stop'
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)
if (-not $isAdmin) { throw 'Run this script from PowerShell as Administrator.' }

$outputDirectory = Join-Path $ProjectRoot 'inventory\event-log-maintenance'
New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null
$resultPath = Join-Path $outputDirectory ("clear-standard-logs-{0}.json" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
$result = [ordered]@{
    StartedAt = (Get-Date).ToString('o')
    Cleared = @()
    Failed = @()
    VerboseChannelsDisabled = @()
    SecurityLogCleared = $false
}

foreach ($logName in @('System', 'Application')) {
    try {
        & "$env:SystemRoot\System32\wevtutil.exe" clear-log $logName
        if ($LASTEXITCODE -ne 0) { throw "wevtutil exit code $LASTEXITCODE" }
        $result.Cleared += $logName
    } catch {
        $result.Failed += "$logName`: $($_.Exception.Message)"
    }
}

$verboseChannels = @(Get-WinEvent -ListLog * -ErrorAction SilentlyContinue | Where-Object {
    $_.IsEnabled -and ($_.LogType -eq 'Analytical' -or $_.LogType -eq 'Debug')
})
foreach ($channel in $verboseChannels) {
    & "$env:SystemRoot\System32\wevtutil.exe" set-log $channel.LogName /enabled:false
    if ($LASTEXITCODE -eq 0) {
        $result.VerboseChannelsDisabled += $channel.LogName
    } else {
        $result.Failed += "$($channel.LogName): disable failed with exit code $LASTEXITCODE"
    }
}

$result.RemainingSystemCriticalErrors = @(Get-WinEvent -FilterHashtable @{LogName='System'; Level=1,2} -ErrorAction SilentlyContinue).Count
$result.RemainingApplicationCriticalErrors = @(Get-WinEvent -FilterHashtable @{LogName='Application'; Level=1,2} -ErrorAction SilentlyContinue).Count
$result.CompletedAt = (Get-Date).ToString('o')
$result.Status = if ($result.Failed.Count) { 'PASS_WITH_WARNINGS' } else { 'PASS' }
$result | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $resultPath -Encoding utf8
$result | ConvertTo-Json -Depth 5
if ($result.Failed.Count) { exit 1 }
