[CmdletBinding()]
param(
    [string]$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..\..')).Path,
    [string]$Description = 'Windows 11 (Hypervisor Off)'
)

$ErrorActionPreference = 'Stop'
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)
if (-not $isAdmin) { throw 'Run this script from PowerShell as Administrator.' }

$bcdedit = Join-Path $env:SystemRoot 'System32\bcdedit.exe'
$outputDirectory = Join-Path $ProjectRoot 'inventory\boot-options'
New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backupPath = Join-Path $outputDirectory "BCD-before-removing-hypervisor-off-$stamp.bak"
$resultPath = Join-Path $outputDirectory "remove-hypervisor-off-$stamp.json"

$history = @(Get-ChildItem -LiteralPath $outputDirectory -Filter 'hypervisor-off-*.json' -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending |
    ForEach-Object { Get-Content -Raw -LiteralPath $_.FullName | ConvertFrom-Json } |
    Where-Object { $_.Status -eq 'PASS' -and $_.Description -eq $Description -and $_.Identifier })
if (-not $history.Count) { throw "No successful project record for '$Description' was found. No change was made." }
$identifier = $history[0].Identifier

$exportOutput = @(& $bcdedit /export $backupPath 2>&1)
if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $backupPath)) {
    throw "BCD backup failed: $($exportOutput -join ' ')"
}

$entryOutput = @(& $bcdedit /enum $identifier /v 2>&1)
if ($LASTEXITCODE -ne 0) { throw "The recorded entry $identifier does not exist. No change was made." }
if (($entryOutput -join "`n") -notmatch [regex]::Escape($Description)) {
    throw "The recorded entry no longer has the expected description. No change was made."
}

$deleteOutput = @(& $bcdedit /delete $identifier /cleanup 2>&1)
if ($LASTEXITCODE -ne 0) { throw "Failed to delete $identifier`: $($deleteOutput -join ' ')" }

$result = [ordered]@{
    Status = 'PASS'
    CompletedAt = (Get-Date).ToString('o')
    RemovedIdentifier = $identifier
    Description = $Description
    BackupPath = $backupPath
    DefaultEntryChanged = $false
}
$result | ConvertTo-Json -Depth 3 | Set-Content -LiteralPath $resultPath -Encoding utf8
$result | ConvertTo-Json -Depth 3
