[CmdletBinding()]
param(
    [string]$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..\..')).Path,
    [string]$Description = 'Windows 11 (Hypervisor Off)',
    [ValidateRange(3, 60)]
    [int]$MenuTimeoutSeconds = 8
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
$backupPath = Join-Path $outputDirectory "BCD-before-hypervisor-off-$stamp.bak"
$resultPath = Join-Path $outputDirectory "hypervisor-off-$stamp.json"
$createdIdentifier = $null
$result = [ordered]@{
    StartedAt = (Get-Date).ToString('o')
    Status = 'STARTED'
    Description = $Description
    DefaultEntryChanged = $false
    BackupPath = $backupPath
}

function Invoke-BcdEdit {
    param([string[]]$Arguments)
    $output = @(& $bcdedit @Arguments 2>&1)
    $exitCode = $LASTEXITCODE
    [pscustomobject]@{ Output = $output; ExitCode = $exitCode; Text = ($output -join "`n") }
}

try {
    $existing = Invoke-BcdEdit @('/enum','all','/v')
    if ($existing.ExitCode -ne 0) { throw "Cannot read the BCD store: $($existing.Text)" }
    if ($existing.Text -match [regex]::Escape($Description)) {
        throw "A boot entry named '$Description' already exists. No change was made."
    }

    $export = Invoke-BcdEdit @('/export', $backupPath)
    if ($export.ExitCode -ne 0 -or -not (Test-Path -LiteralPath $backupPath)) {
        throw "BCD backup failed: $($export.Text)"
    }

    $copy = Invoke-BcdEdit @('/copy', '{current}', '/d', $Description)
    if ($copy.ExitCode -ne 0) { throw "Boot-entry copy failed: $($copy.Text)" }
    $guidMatch = [regex]::Match($copy.Text, '\{[0-9a-fA-F-]{36}\}')
    if (-not $guidMatch.Success) { throw "The new boot-entry identifier could not be parsed: $($copy.Text)" }
    $createdIdentifier = $guidMatch.Value
    $result.Identifier = $createdIdentifier

    foreach ($setting in @(
        @($createdIdentifier, 'hypervisorlaunchtype', 'Off'),
        @($createdIdentifier, 'vsmlaunchtype', 'Off')
    )) {
        $setResult = Invoke-BcdEdit (@('/set') + $setting)
        if ($setResult.ExitCode -ne 0) {
            throw "Failed to set $($setting[1]) on $createdIdentifier`: $($setResult.Text)"
        }
    }

    $timeout = Invoke-BcdEdit @('/timeout', $MenuTimeoutSeconds.ToString())
    if ($timeout.ExitCode -ne 0) { throw "Failed to set the boot-menu timeout: $($timeout.Text)" }

    $verify = Invoke-BcdEdit @('/enum', $createdIdentifier, '/v')
    if ($verify.ExitCode -ne 0) { throw "Cannot verify the new entry: $($verify.Text)" }
    if ($verify.Text -notmatch '(?im)^\s*hypervisorlaunchtype\s+Off\s*$') {
        throw 'Verification failed: hypervisorlaunchtype is not Off.'
    }
    if ($verify.Text -notmatch '(?im)^\s*vsmlaunchtype\s+Off\s*$') {
        throw 'Verification failed: vsmlaunchtype is not Off.'
    }

    $result.Status = 'PASS'
    $result.MenuTimeoutSeconds = $MenuTimeoutSeconds
    $result.RestartRequired = $true
    $result.Verification = $verify.Text
} catch {
    $result.Status = 'FAIL'
    $result.Error = $_.Exception.Message
    if ($createdIdentifier) {
        $rollback = Invoke-BcdEdit @('/delete', $createdIdentifier, '/cleanup')
        $result.RollbackAttempted = $true
        $result.RollbackSucceeded = ($rollback.ExitCode -eq 0)
        $result.RollbackOutput = $rollback.Text
    }
} finally {
    $result.CompletedAt = (Get-Date).ToString('o')
    $result | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $resultPath -Encoding utf8
}

$result | ConvertTo-Json -Depth 5
if ($result.Status -ne 'PASS') { exit 1 }
