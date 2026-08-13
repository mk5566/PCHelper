[CmdletBinding()]
param(
    [string]$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..\..')).Path
)

$ErrorActionPreference = 'Stop'
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)
if (-not $isAdmin) { throw 'Run this script from PowerShell as Administrator.' }

$outputDirectory = Join-Path $ProjectRoot 'inventory\defender-cleanup'
New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$resultPath = Join-Path $outputDirectory "result-$stamp.json"
$serviceBackupPath = Join-Path $outputDirectory "MDCoreSvc-$stamp.reg"
$securityCenterBackupPath = Join-Path $outputDirectory "security-center-$stamp.json"
$dismFeaturesPath = Join-Path $outputDirectory "dism-features-$stamp.txt"
$dismHealthPath = Join-Path $outputDirectory "dism-checkhealth-$stamp.txt"

$result = [ordered]@{
    StartedAt = (Get-Date).ToString('o')
    IsAdministrator = $true
    Changes = [System.Collections.Generic.List[string]]::new()
    Warnings = [System.Collections.Generic.List[string]]::new()
}

try {
    $service = Get-CimInstance Win32_Service -Filter "Name='MDCoreSvc'" -ErrorAction SilentlyContinue
    if ($service) {
        & reg.exe export 'HKLM\SYSTEM\CurrentControlSet\Services\MDCoreSvc' $serviceBackupPath /y | Out-Null
        if ($LASTEXITCODE -ne 0) { throw 'Failed to back up the MDCoreSvc registry definition.' }

        if ($service.State -eq 'Running') {
            $stopOutput = @(& sc.exe stop MDCoreSvc 2>&1)
            $result.MDCoreSvcStop = ($stopOutput -join "`n")
        }

        $configOutput = @(& sc.exe config MDCoreSvc start= disabled 2>&1)
        $configExitCode = $LASTEXITCODE
        $result.MDCoreSvcConfig = ($configOutput -join "`n")
        $result.MDCoreSvcConfigExitCode = $configExitCode

        if ($configExitCode -eq 0) {
            $result.Changes.Add('Backed up and disabled the orphan MDCoreSvc service through Service Control Manager.')
        } else {
            try {
                Set-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Services\MDCoreSvc' -Name Start -Type DWord -Value 4
                $result.Changes.Add('Backed up MDCoreSvc and set its registry start mode to Disabled; restart is required for Service Control Manager to reload it.')
                $result.Warnings.Add("Service Control Manager rejected the change: $($configOutput -join ' ')")
                $result.RestartRequired = $true
            } catch {
                $result.Warnings.Add("MDCoreSvc could not be disabled: $($configOutput -join ' '); registry fallback: $($_.Exception.Message)")
            }
        }
    }

    $defenderRegistrations = @(Get-CimInstance -Namespace root/SecurityCenter2 -ClassName AntivirusProduct |
        Where-Object displayName -eq 'Windows Defender')
    $defenderRegistrations |
        Select-Object displayName,pathToSignedProductExe,pathToSignedReportingExe,productState |
        ConvertTo-Json -Depth 3 | Set-Content -LiteralPath $securityCenterBackupPath -Encoding utf8
    if ($defenderRegistrations.Count) {
        try {
            foreach ($registration in $defenderRegistrations) {
                Remove-CimInstance -InputObject $registration
            }
            $result.Changes.Add('Removed the stale Windows Defender antivirus registration from Windows Security Center.')
        } catch {
            $result.Warnings.Add("The stale Windows Defender Security Center registration could not be removed: $($_.Exception.Message)")
        }
    }

    $featuresOutput = & "$env:SystemRoot\System32\Dism.exe" /Online /Get-Features /Format:Table /English 2>&1
    $featuresExitCode = $LASTEXITCODE
    $featuresOutput | Set-Content -LiteralPath $dismFeaturesPath -Encoding utf8
    $result.DismGetFeaturesExitCode = $featuresExitCode

    $healthOutput = & "$env:SystemRoot\System32\Dism.exe" /Online /Cleanup-Image /CheckHealth /English 2>&1
    $healthExitCode = $LASTEXITCODE
    $healthOutput | Set-Content -LiteralPath $dismHealthPath -Encoding utf8
    $result.DismCheckHealthExitCode = $healthExitCode

    $serviceAfter = Get-CimInstance Win32_Service -Filter "Name='MDCoreSvc'" -ErrorAction SilentlyContinue
    $serviceRegistryStart = (Get-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Services\MDCoreSvc' -Name Start -ErrorAction SilentlyContinue).Start
    $registrationsAfter = @(Get-CimInstance -Namespace root/SecurityCenter2 -ClassName AntivirusProduct -ErrorAction SilentlyContinue |
        Select-Object displayName,productState)

    $result.Verification = [ordered]@{
        MDCoreSvcPresent = $null -ne $serviceAfter
        MDCoreSvcState = if ($serviceAfter) { $serviceAfter.State } else { $null }
        MDCoreSvcStartMode = if ($serviceAfter) { $serviceAfter.StartMode } else { $null }
        MDCoreSvcRegistryStart = $serviceRegistryStart
        AntivirusRegistrations = $registrationsAfter
        NativeDismGetFeaturesSucceeded = ($featuresExitCode -eq 0)
        DismCheckHealthSucceeded = ($healthExitCode -eq 0)
    }

    if ($featuresExitCode -ne 0) { $result.Warnings.Add("Native DISM Get-Features failed with exit code $featuresExitCode.") }
    if ($healthExitCode -ne 0) { $result.Warnings.Add("DISM CheckHealth failed with exit code $healthExitCode.") }

    $result.Status = if ($result.Warnings.Count) { 'PASS_WITH_WARNINGS' } else { 'PASS' }
} catch {
    $result.Status = 'FAIL'
    $result.Error = $_.Exception.Message
    $result.Details = ($_ | Out-String)
} finally {
    $result.CompletedAt = (Get-Date).ToString('o')
    $result | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $resultPath -Encoding utf8
}

$result | ConvertTo-Json -Depth 6
if ($result.Status -eq 'FAIL') { exit 1 }
