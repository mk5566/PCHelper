[CmdletBinding()]
param(
    [string]$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..\..')).Path
)

$ErrorActionPreference = 'Stop'
$resultPath = Join-Path $ProjectRoot 'inventory\admin-scan-result.json'

try {
    Set-Location -LiteralPath $ProjectRoot
    $collectorOutput = (& (Join-Path $PSScriptRoot 'Collect-PCInventory.ps1') -ProjectRoot $ProjectRoot | Out-String)
    $validatorOutput = (& (Join-Path $PSScriptRoot 'Test-PCInventory.ps1') -ProjectRoot $ProjectRoot | Out-String)

    [pscustomobject]@{
        Status = 'PASS'
        CompletedAt = (Get-Date).ToString('o')
        IsAdministrator = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
            [Security.Principal.WindowsBuiltInRole]::Administrator
        )
        Collector = $collectorOutput
        Validator = $validatorOutput
    } | ConvertTo-Json -Depth 3 | Set-Content -LiteralPath $resultPath -Encoding utf8
    exit 0
} catch {
    [pscustomobject]@{
        Status = 'FAIL'
        CompletedAt = (Get-Date).ToString('o')
        IsAdministrator = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
            [Security.Principal.WindowsBuiltInRole]::Administrator
        )
        Error = $_.Exception.Message
        Details = ($_ | Out-String)
    } | ConvertTo-Json -Depth 3 | Set-Content -LiteralPath $resultPath -Encoding utf8
    exit 1
}
