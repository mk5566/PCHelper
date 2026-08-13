[CmdletBinding()]
param(
    [string]$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..\..')).Path
)

$ErrorActionPreference = 'Stop'
$inventoryPath = Join-Path $ProjectRoot 'inventory\raw\inventory.json'
$profilePath = Join-Path $ProjectRoot 'inventory\PC_PROFILE.md'
$appsPath = Join-Path $ProjectRoot 'inventory\raw\desktop-apps.csv'
$driversPath = Join-Path $ProjectRoot 'inventory\raw\drivers.csv'
$devicesPath = Join-Path $ProjectRoot 'inventory\raw\hardware-devices.csv'

$required = @($inventoryPath, $profilePath, $appsPath, $driversPath, $devicesPath)
$missing = @($required | Where-Object { -not (Test-Path -LiteralPath $_) })
if ($missing.Count -gt 0) {
    throw "Missing inventory output: $($missing -join ', ')"
}

$inventory = Get-Content -Raw -LiteralPath $inventoryPath | ConvertFrom-Json
foreach ($property in 'Metadata','System','Hardware','Storage','Network','Security','Software','Health','CollectionWarnings') {
    if ($null -eq $inventory.$property) {
        throw "inventory.json is missing required section: $property"
    }
}

$forbiddenPropertyNames = @(
    'Password','ProductKey','RecoveryKey','KeyProtector','SerialNumber',
    'MacAddress','IPAddress','DefaultGateway','DnsDomain','UserName','SID',
    'UninstallString','InstallLocation','PackageFullName'
)
$raw = Get-Content -Raw -LiteralPath $inventoryPath
foreach ($name in $forbiddenPropertyNames) {
    if ($raw -match ('"' + [regex]::Escape($name) + '"\s*:')) {
        throw "Privacy check failed: forbidden property '$name' is present."
    }
}
foreach ($pattern in 'S-1-5-21-','C:\\Users\\[^\\\"]+') {
    if ($raw -match $pattern) {
        throw "Privacy check failed: user-specific identifier pattern is present."
    }
}

if ($inventory.Metadata.SchemaVersion -ne '1.0') {
    throw "Unexpected schema version: $($inventory.Metadata.SchemaVersion)"
}

[pscustomobject]@{
    Status = 'PASS'
    CollectedAt = $inventory.Metadata.CollectedAt
    IsAdministrator = $inventory.Metadata.IsAdministrator
    WarningCount = @($inventory.CollectionWarnings).Count
    DesktopAppCount = @($inventory.Software.DesktopApps).Count
    StoreAppCount = @($inventory.Software.StoreApps).Count
    HardwareDeviceCount = @($inventory.Hardware.Devices).Count
    Output = $profilePath
} | Format-List
