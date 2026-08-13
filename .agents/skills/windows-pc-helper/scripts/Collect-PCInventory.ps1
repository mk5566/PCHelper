[CmdletBinding()]
param(
    [string]$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..\..')).Path
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$warnings = [System.Collections.Generic.List[object]]::new()

function Add-CollectionWarning {
    param([string]$Section, [System.Management.Automation.ErrorRecord]$ErrorRecord)
    $warnings.Add([pscustomobject]@{
        Section = $Section
        ErrorType = $ErrorRecord.Exception.GetType().Name
        Message = $ErrorRecord.Exception.Message
    })
}

function Get-SafeData {
    param([string]$Section, [scriptblock]$Action, $Fallback = @())
    try {
        $ErrorActionPreference = 'Stop'
        & $Action
    } catch {
        Add-CollectionWarning -Section $Section -ErrorRecord $_
        $Fallback
    }
}

function ConvertTo-GiB {
    param($Bytes)
    if ($null -eq $Bytes) { return $null }
    [math]::Round(([double]$Bytes / 1GB), 2)
}

function Convert-CimDate {
    param($Value)
    if ($null -eq $Value) { return $null }
    try { ([datetime]$Value).ToString('o') } catch { $Value.ToString() }
}

function Get-RegistryApps {
    $locations = @(
        @{ Path = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'; Scope = 'Machine'; Architecture = '64-bit' },
        @{ Path = 'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'; Scope = 'Machine'; Architecture = '32-bit' },
        @{ Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'; Scope = 'Current user'; Architecture = 'Per-user' }
    )
    $apps = foreach ($location in $locations) {
        Get-ItemProperty -Path $location.Path -ErrorAction SilentlyContinue |
            Where-Object { -not [string]::IsNullOrWhiteSpace($_.DisplayName) } |
            ForEach-Object {
                [pscustomobject]@{
                    Name = $_.DisplayName.Trim()
                    Version = $_.DisplayVersion
                    Publisher = $_.Publisher
                    InstallDate = $_.InstallDate
                    Scope = $location.Scope
                    Architecture = $location.Architecture
                    EstimatedSizeKB = $_.EstimatedSize
                }
            }
    }
    @($apps | Sort-Object Name, Version, Scope -Unique)
}

function Get-CommandVersion {
    param([string]$Name, [string[]]$Arguments = @('--version'))
    $command = Get-Command $Name -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $command) { return $null }
    $versionText = $null
    try { $versionText = ((& $command.Source @Arguments 2>&1 | Select-Object -First 3) -join ' ').Trim() } catch {}
    [pscustomobject]@{ Name = $Name; VersionOutput = $versionText }
}

$outputDirectory = Join-Path $ProjectRoot 'inventory'
$rawDirectory = Join-Path $outputDirectory 'raw'
New-Item -ItemType Directory -Force -Path $rawDirectory | Out-Null

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)
$now = Get-Date

$os = Get-SafeData 'Operating system' {
    Get-CimInstance Win32_OperatingSystem | ForEach-Object {
        [pscustomobject]@{
            Caption = $_.Caption
            Version = $_.Version
            BuildNumber = $_.BuildNumber
            Architecture = $_.OSArchitecture
            InstallDate = Convert-CimDate $_.InstallDate
            LastBoot = Convert-CimDate $_.LastBootUpTime
            UptimeDays = [math]::Round(($now - [datetime]$_.LastBootUpTime).TotalDays, 2)
        }
    }
} $null

$computerSystem = Get-SafeData 'Computer system' {
    Get-CimInstance Win32_ComputerSystem | ForEach-Object {
        [pscustomobject]@{
            Manufacturer = $_.Manufacturer
            Model = $_.Model
            SystemType = $_.SystemType
            TotalMemoryGB = ConvertTo-GiB $_.TotalPhysicalMemory
            HypervisorPresent = $_.HypervisorPresent
        }
    }
} $null

$computerProduct = Get-SafeData 'Computer product' {
    Get-CimInstance Win32_ComputerSystemProduct | ForEach-Object {
        [pscustomobject]@{ Vendor = $_.Vendor; ProductCode = $_.Name; ProductName = $_.Version }
    }
} $null

$bios = Get-SafeData 'BIOS' {
    Get-CimInstance Win32_BIOS | ForEach-Object {
        [pscustomobject]@{
            Manufacturer = $_.Manufacturer
            Version = $_.SMBIOSBIOSVersion
            ReleaseDate = Convert-CimDate $_.ReleaseDate
        }
    }
} $null

$baseboard = Get-SafeData 'Baseboard' {
    Get-CimInstance Win32_BaseBoard | ForEach-Object {
        [pscustomobject]@{ Manufacturer = $_.Manufacturer; Product = $_.Product }
    }
} $null

$processors = @(Get-SafeData 'Processors' {
    Get-CimInstance Win32_Processor | ForEach-Object {
        [pscustomobject]@{
            Name = $_.Name.Trim()
            Manufacturer = $_.Manufacturer
            Cores = $_.NumberOfCores
            LogicalProcessors = $_.NumberOfLogicalProcessors
            MaxClockMHz = $_.MaxClockSpeed
            VirtualizationFirmwareEnabled = $_.VirtualizationFirmwareEnabled
        }
    }
})

$memory = @(Get-SafeData 'Memory modules' {
    Get-CimInstance Win32_PhysicalMemory | ForEach-Object {
        [pscustomobject]@{
            Bank = $_.BankLabel
            Manufacturer = $_.Manufacturer
            PartNumber = if ($_.PartNumber) { $_.PartNumber.Trim() } else { $null }
            CapacityGB = ConvertTo-GiB $_.Capacity
            SpeedMHz = $_.Speed
            ConfiguredSpeedMHz = $_.ConfiguredClockSpeed
            SMBIOSMemoryType = $_.SMBIOSMemoryType
        }
    }
})

$gpus = @(Get-SafeData 'Graphics adapters' {
    Get-CimInstance Win32_VideoController | ForEach-Object {
        [pscustomobject]@{
            Name = $_.Name
            DriverVersion = $_.DriverVersion
            DriverDate = Convert-CimDate $_.DriverDate
            AdapterRAMGB = ConvertTo-GiB $_.AdapterRAM
            CurrentMode = $_.VideoModeDescription
            Status = $_.Status
        }
    }
})

$monitors = @(Get-SafeData 'Monitors' {
    Get-CimInstance Win32_DesktopMonitor | ForEach-Object {
        [pscustomobject]@{
            Name = $_.Name
            Manufacturer = $_.MonitorManufacturer
            Width = $_.ScreenWidth
            Height = $_.ScreenHeight
            Status = $_.Status
        }
    }
})

$batteries = @(Get-SafeData 'Battery' {
    Get-CimInstance Win32_Battery | ForEach-Object {
        [pscustomobject]@{
            Name = $_.Name
            Status = $_.Status
            EstimatedChargeRemaining = $_.EstimatedChargeRemaining
            BatteryStatus = $_.BatteryStatus
            Chemistry = $_.Chemistry
        }
    }
})

$physicalDisks = @(Get-SafeData 'Physical disks' {
    Get-PhysicalDisk | ForEach-Object {
        [pscustomobject]@{
            FriendlyName = $_.FriendlyName
            MediaType = $_.MediaType
            BusType = $_.BusType
            SizeGB = ConvertTo-GiB $_.Size
            HealthStatus = $_.HealthStatus
            OperationalStatus = ($_.OperationalStatus -join ', ')
        }
    }
})

$volumes = @(Get-SafeData 'Volumes' {
    Get-Volume | Where-Object DriveLetter | ForEach-Object {
        [pscustomobject]@{
            Drive = "$($_.DriveLetter):"
            FileSystem = $_.FileSystem
            SizeGB = ConvertTo-GiB $_.Size
            FreeGB = ConvertTo-GiB $_.SizeRemaining
            FreePercent = if ($_.Size) { [math]::Round(100 * $_.SizeRemaining / $_.Size, 1) } else { $null }
            HealthStatus = $_.HealthStatus
            OperationalStatus = ($_.OperationalStatus -join ', ')
        }
    }
})

$networkAdapters = @(Get-SafeData 'Network adapters' {
    Get-NetAdapter -Physical | ForEach-Object {
        [pscustomobject]@{
            Name = $_.Name
            Description = $_.InterfaceDescription
            Status = $_.Status
            LinkSpeed = $_.LinkSpeed
            MediaType = $_.MediaType
            DriverInformation = $_.DriverInformation
        }
    }
})

$networkState = @(Get-SafeData 'Network configuration summary' {
    Get-NetIPConfiguration | ForEach-Object {
        [pscustomobject]@{
            Interface = $_.InterfaceAlias
            InterfaceUp = ($_.NetAdapter.Status -eq 'Up')
            HasIPv4Address = @($_.IPv4Address).Count -gt 0
            HasIPv6Address = @($_.IPv6Address).Count -gt 0
            HasDefaultRoute = $null -ne $_.IPv4DefaultGateway -or $null -ne $_.IPv6DefaultGateway
            DnsServerCount = @($_.DNSServer.ServerAddresses).Count
        }
    }
})

$defender = Get-SafeData 'Microsoft Defender' {
    Get-MpComputerStatus -ErrorAction Stop | Select-Object AMServiceEnabled,AntivirusEnabled,AntispywareEnabled,BehaviorMonitorEnabled,
        IoavProtectionEnabled,NISEnabled,OnAccessProtectionEnabled,RealTimeProtectionEnabled,IsTamperProtected,
        AntivirusSignatureVersion,AntivirusSignatureLastUpdated,AMEngineVersion,QuickScanAge,FullScanAge,
        ComputerState,RebootRequired
} $null

$securityCenterProducts = @(Get-SafeData 'Windows Security Center products' {
    Get-CimInstance -Namespace root/SecurityCenter2 -ClassName AntivirusProduct | ForEach-Object {
        [pscustomobject]@{ Name = $_.displayName; ProductState = $_.productState }
    }
})
$securityCenterQuerySucceeded = @($warnings | Where-Object Section -eq 'Windows Security Center products').Count -eq 0

$securityServices = @(Get-SafeData 'Windows security services' {
    foreach ($serviceName in 'WinDefend','SecurityHealthService','wscsvc','mpssvc') {
        Get-Service -Name $serviceName -ErrorAction SilentlyContinue | ForEach-Object {
            [pscustomobject]@{
                Name = $_.Name
                Status = $_.Status.ToString()
                StartType = $_.StartType.ToString()
            }
        }
    }
})
$removedDefenderState = Get-SafeData 'Removed Defender state' {
    $service = Get-CimInstance Win32_Service -Filter "Name='MDCoreSvc'" -ErrorAction SilentlyContinue
    [pscustomobject]@{
        MDCoreSvcPresent = $null -ne $service
        MDCoreSvcState = if ($service) { $service.State } else { $null }
        MDCoreSvcStartMode = if ($service) { $service.StartMode } else { $null }
        PlatformExecutablePresent = Test-Path -LiteralPath 'C:\Program Files\Windows Defender\MpDefenderCoreService.exe'
    }
} $null
$defenderIntentionallyAbsent = $removedDefenderState -and
    $removedDefenderState.MDCoreSvcPresent -and
    $removedDefenderState.MDCoreSvcState -eq 'Stopped' -and
    $removedDefenderState.MDCoreSvcStartMode -eq 'Disabled' -and
    -not $removedDefenderState.PlatformExecutablePresent -and
    $securityCenterQuerySucceeded -and $securityCenterProducts.Count -eq 0
if ($defenderIntentionallyAbsent) {
    @($warnings | Where-Object Section -eq 'Microsoft Defender') | ForEach-Object {
        [void]$warnings.Remove($_)
    }
}

$firewall = @(Get-SafeData 'Firewall' {
    Get-NetFirewallProfile | ForEach-Object {
        [pscustomobject]@{
            Name = $_.Name
            Enabled = $_.Enabled
            DefaultInboundAction = $_.DefaultInboundAction
            DefaultOutboundAction = $_.DefaultOutboundAction
        }
    }
})

$bitLocker = @(Get-SafeData 'BitLocker' {
    Get-BitLockerVolume -ErrorAction Stop | ForEach-Object {
        [pscustomobject]@{
            MountPoint = $_.MountPoint
            VolumeStatus = $_.VolumeStatus
            ProtectionStatus = $_.ProtectionStatus
            EncryptionPercentage = $_.EncryptionPercentage
            EncryptionMethod = $_.EncryptionMethod
            LockStatus = $_.LockStatus
        }
    }
})

$tpm = $null
$tpmPrimaryError = $null
try {
    $tpm = Get-Tpm -ErrorAction Stop | Select-Object TpmPresent,TpmReady,TpmEnabled,TpmActivated,ManufacturerIdTxt,ManufacturerVersion
    if ($null -eq $tpm.TpmPresent -and $null -eq $tpm.TpmReady) { $tpm = $null }
} catch { $tpmPrimaryError = $_ }
if ($null -eq $tpm) {
    try {
        $tpmToolText = ((tpmtool getdeviceinformation 2>&1) -join "`n")
        if ($LASTEXITCODE -ne 0) { throw "tpmtool exited with code $LASTEXITCODE" }
        $getTpmValue = {
            param([string]$Label)
            $match = [regex]::Match($tpmToolText, '(?m)^-' + [regex]::Escape($Label) + ':\s*(.+)$')
            if ($match.Success) { $match.Groups[1].Value.Trim() } else { $null }
        }
        $tpm = [pscustomobject]@{
            TpmPresent = ((& $getTpmValue 'TPM Present') -eq 'True')
            TpmReady = ((& $getTpmValue 'Ready For Storage') -eq 'True')
            TpmInitialized = ((& $getTpmValue 'Is Initialized') -eq 'True')
            TpmVersion = (& $getTpmValue 'TPM Version')
            Manufacturer = (& $getTpmValue 'TPM Manufacturer Full Name')
            ManufacturerVersion = (& $getTpmValue 'TPM Manufacturer Version')
            VulnerableFirmwareReported = ((& $getTpmValue 'TPM Has Vulnerable Firmware') -eq 'True')
        }
    } catch {
        $errorToRecord = if ($tpmPrimaryError) { $tpmPrimaryError } else { $_ }
        Add-CollectionWarning -Section 'TPM' -ErrorRecord $errorToRecord
        $tpm = $null
    }
}

$secureBoot = $null
$secureBootPrimaryError = $null
try { $secureBoot = [bool](Confirm-SecureBootUEFI -ErrorAction Stop) } catch { $secureBootPrimaryError = $_ }
if ($null -eq $secureBoot) {
    try {
        $secureBootValue = (Get-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\SecureBoot\State' -Name UEFISecureBootEnabled -ErrorAction Stop).UEFISecureBootEnabled
        $secureBoot = ($secureBootValue -eq 1)
    } catch {
        $errorToRecord = if ($secureBootPrimaryError) { $secureBootPrimaryError } else { $_ }
        Add-CollectionWarning -Section 'Secure Boot' -ErrorRecord $errorToRecord
    }
}

$uac = Get-SafeData 'User Account Control' {
    $value = Get-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
    [pscustomobject]@{
        Enabled = ($value.EnableLUA -eq 1)
        AdminConsentPromptLevel = $value.ConsentPromptBehaviorAdmin
        SecureDesktopPrompt = ($value.PromptOnSecureDesktop -eq 1)
    }
} $null

$desktopApps = @(Get-SafeData 'Desktop applications' { Get-RegistryApps })
$storeApps = @(Get-SafeData 'Store applications' {
    Get-AppxPackage | Where-Object { -not $_.IsFramework -and -not $_.IsResourcePackage } | ForEach-Object {
        [pscustomobject]@{
            Name = $_.Name
            Version = $_.Version.ToString()
            Publisher = $_.PublisherDisplayName
            Architecture = $_.Architecture.ToString()
            SignatureKind = $_.SignatureKind.ToString()
        }
    } | Sort-Object Name -Unique
})

$optionalFeatures = @()
$optionalFeatureSource = $null
try {
    $ErrorActionPreference = 'Stop'
    $optionalFeatures = @(Get-WindowsOptionalFeature -Online -ErrorAction Stop |
        Where-Object State -eq 'Enabled' |
        Select-Object FeatureName, State)
    $optionalFeatureSource = 'PowerShell DISM provider'
} catch {
    $providerError = $_
    try {
        $dismFeatureOutput = @(& "$env:SystemRoot\System32\Dism.exe" /Online /Get-Features /Format:Table /English 2>&1)
        $dismFeatureExitCode = $LASTEXITCODE
        if ($dismFeatureExitCode -ne 0) { throw "Dism.exe exited with code $dismFeatureExitCode." }
        $optionalFeatures = @($dismFeatureOutput | ForEach-Object {
            if ($_ -match '^\s*(\S+)\s+\|\s+Enabled\s*$') {
                [pscustomobject]@{ FeatureName = $matches[1]; State = 'Enabled' }
            }
        })
        $optionalFeatureSource = 'Native Dism.exe fallback'
    } catch {
        Add-CollectionWarning -Section 'Windows optional features' -ErrorRecord $providerError
        Add-CollectionWarning -Section 'Native DISM optional features fallback' -ErrorRecord $_
    }
}

$drivers = @(Get-SafeData 'Signed drivers' {
    Get-CimInstance Win32_PnPSignedDriver | Where-Object DeviceName | ForEach-Object {
        [pscustomobject]@{
            DeviceName = $_.DeviceName
            DeviceClass = $_.DeviceClass
            Manufacturer = $_.Manufacturer
            DriverProvider = $_.DriverProviderName
            DriverVersion = $_.DriverVersion
            DriverDate = Convert-CimDate $_.DriverDate
            InfName = $_.InfName
            IsSigned = $_.IsSigned
        }
    } | Sort-Object DeviceClass, DeviceName
})

$devices = @(Get-SafeData 'Plug and Play devices' {
    Get-PnpDevice -PresentOnly | Where-Object FriendlyName | ForEach-Object {
        [pscustomobject]@{
            Class = $_.Class
            FriendlyName = $_.FriendlyName
            Status = $_.Status
            Problem = $_.Problem
        }
    } | Sort-Object Class, FriendlyName
})

$services = @(Get-SafeData 'Services' {
    Get-CimInstance Win32_Service | ForEach-Object {
        [pscustomobject]@{
            Name = $_.Name
            DisplayName = $_.DisplayName
            State = $_.State
            StartMode = $_.StartMode
        }
    } | Sort-Object Name
})

$startupApps = @(Get-SafeData 'Startup applications' {
    Get-CimInstance Win32_StartupCommand | ForEach-Object {
        [pscustomobject]@{ Name = $_.Name }
    } | Sort-Object Name -Unique
})

$hotfixes = @(Get-SafeData 'Installed Windows updates' {
    Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 50 HotFixID, Description, InstalledOn
})

$updateService = Get-SafeData 'Windows Update service' {
    Get-Service wuauserv | Select-Object Name, Status, StartType
} $null

$pendingReboot = [pscustomobject]@{
    ComponentServicing = Test-Path -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'
    WindowsUpdate = Test-Path -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
    PendingFileRename = $null -ne (Get-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Name PendingFileRenameOperations -ErrorAction SilentlyContinue).PendingFileRenameOperations
}

$recentCriticalEvents = @(Get-SafeData 'Recent critical and error event summary' {
    $start = (Get-Date).AddDays(-7)
    Get-WinEvent -FilterHashtable @{ LogName = 'System'; Level = 1,2; StartTime = $start } -ErrorAction Stop |
        Group-Object ProviderName, Id, LevelDisplayName |
        ForEach-Object {
            $sample = $_.Group | Sort-Object TimeCreated -Descending | Select-Object -First 1
            [pscustomobject]@{
                Provider = $sample.ProviderName
                EventId = $sample.Id
                Level = $sample.LevelDisplayName
                Count7Days = $_.Count
                LastSeen = Convert-CimDate $sample.TimeCreated
            }
        } | Sort-Object Count7Days -Descending | Select-Object -First 50
})

$powerScheme = Get-SafeData 'Active power scheme' {
    ((powercfg /getactivescheme 2>&1) -join ' ').Trim()
} $null

$developerTools = @(
    Get-CommandVersion 'pwsh'
    Get-CommandVersion 'powershell' @('-NoProfile','-Command','$PSVersionTable.PSVersion.ToString()')
    Get-CommandVersion 'winget'
    Get-CommandVersion 'git'
    Get-CommandVersion 'python'
    Get-CommandVersion 'py' @('--version')
    Get-CommandVersion 'node'
    Get-CommandVersion 'npm'
    Get-CommandVersion 'dotnet'
    Get-CommandVersion 'java'
    Get-CommandVersion 'wsl' @('--version')
) | Where-Object { $null -ne $_ }

$inventory = [ordered]@{
    Metadata = [ordered]@{
        SchemaVersion = '1.0'
        CollectedAt = $now.ToString('o')
        CollectorVersion = '1.0.0'
        PowerShellVersion = $PSVersionTable.PSVersion.ToString()
        PowerShellEdition = $PSVersionTable.PSEdition
        IsAdministrator = $isAdmin
        PrivacyFiltered = $true
    }
    System = [ordered]@{
        OperatingSystem = $os
        Computer = $computerSystem
        Product = $computerProduct
        BIOS = $bios
        Baseboard = $baseboard
        PowerScheme = $powerScheme
        Battery = $batteries
    }
    Hardware = [ordered]@{
        Processors = $processors
        MemoryModules = $memory
        Graphics = $gpus
        Monitors = $monitors
        Devices = $devices
        Drivers = $drivers
    }
    Storage = [ordered]@{
        PhysicalDisks = $physicalDisks
        Volumes = $volumes
    }
    Network = [ordered]@{
        PhysicalAdapters = $networkAdapters
        ConnectivitySummary = $networkState
    }
    Security = [ordered]@{
        Defender = $defender
        SecurityCenterProducts = $securityCenterProducts
        SecurityCenterQuerySucceeded = $securityCenterQuerySucceeded
        SecurityServices = $securityServices
        DefenderIntentionallyAbsent = $defenderIntentionallyAbsent
        RemovedDefenderState = $removedDefenderState
        FirewallProfiles = $firewall
        BitLockerVolumes = $bitLocker
        TPM = $tpm
        SecureBoot = $secureBoot
        UserAccountControl = $uac
    }
    Software = [ordered]@{
        DesktopApps = $desktopApps
        StoreApps = $storeApps
        EnabledOptionalFeatures = $optionalFeatures
        OptionalFeatureInventorySource = $optionalFeatureSource
        Services = $services
        StartupApps = $startupApps
        DeveloperTools = $developerTools
    }
    Health = [ordered]@{
        RecentSystemCriticalAndErrorEvents = $recentCriticalEvents
        RecentHotfixes = $hotfixes
        WindowsUpdateService = $updateService
        PendingReboot = $pendingReboot
    }
    CollectionWarnings = $warnings
}

$inventoryPath = Join-Path $rawDirectory 'inventory.json'
$desktopAppsPath = Join-Path $rawDirectory 'desktop-apps.csv'
$storeAppsPath = Join-Path $rawDirectory 'store-apps.csv'
$driversPath = Join-Path $rawDirectory 'drivers.csv'
$devicesPath = Join-Path $rawDirectory 'hardware-devices.csv'
$servicesPath = Join-Path $rawDirectory 'services.csv'

$inventory | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $inventoryPath -Encoding utf8
$desktopApps | Export-Csv -LiteralPath $desktopAppsPath -NoTypeInformation -Encoding utf8
$storeApps | Export-Csv -LiteralPath $storeAppsPath -NoTypeInformation -Encoding utf8
$drivers | Export-Csv -LiteralPath $driversPath -NoTypeInformation -Encoding utf8
$devices | Export-Csv -LiteralPath $devicesPath -NoTypeInformation -Encoding utf8
$services | Export-Csv -LiteralPath $servicesPath -NoTypeInformation -Encoding utf8

$cpuSummary = if ($processors.Count) { ($processors | ForEach-Object { "$($_.Name) ($($_.Cores) cores / $($_.LogicalProcessors) logical)" }) -join '; ' } else { 'Unavailable' }
$memoryTotal = [math]::Round((($memory | Measure-Object CapacityGB -Sum).Sum), 2)
$gpuSummary = if ($gpus.Count) { ($gpus | ForEach-Object { "$($_.Name) - driver $($_.DriverVersion)" }) -join '; ' } else { 'Unavailable' }
$diskSummary = if ($physicalDisks.Count) { ($physicalDisks | ForEach-Object { "$($_.FriendlyName): $($_.SizeGB) GB, $($_.MediaType), health $($_.HealthStatus)" }) -join '; ' } else { 'Unavailable' }
$problemDevices = @($devices | Where-Object { $_.Status -ne 'OK' -or ($_.Problem -and $_.Problem -ne 'CM_PROB_NONE') })
$lowSpaceVolumes = @($volumes | Where-Object { $null -ne $_.FreePercent -and $_.FreePercent -lt 15 })
$securityGaps = [System.Collections.Generic.List[string]]::new()
if ($defenderIntentionallyAbsent) { }
elseif ($null -eq $defender) { $securityGaps.Add('Detailed Microsoft Defender status was unavailable in this session.') }
elseif (-not $defender.RealTimeProtectionEnabled) { $securityGaps.Add('Microsoft Defender real-time protection is not reported as enabled.') }
if (@($firewall | Where-Object { -not $_.Enabled }).Count -gt 0) { $securityGaps.Add('One or more Windows Firewall profiles are not reported as enabled.') }
if ($secureBoot -eq $false) { $securityGaps.Add('Secure Boot is reported as disabled.') }
elseif ($null -eq $secureBoot) { $securityGaps.Add('Secure Boot status was unavailable in this session.') }
if ($tpm -and $tpm.TpmPresent -and -not $tpm.TpmReady) { $securityGaps.Add('TPM is present but not reported as ready.') }
elseif ($null -eq $tpm) { $securityGaps.Add('TPM status was unavailable in this session.') }
if ($bitLocker.Count -eq 0) { $securityGaps.Add('BitLocker status was not available in this session.') }
if ($uac -and $uac.Enabled -and -not $uac.SecureDesktopPrompt) { $securityGaps.Add('User Account Control is enabled, but elevation prompts are not configured for the secure desktop.') }

$profile = [System.Collections.Generic.List[string]]::new()
$profile.Add('# PC profile')
$profile.Add('')
$profile.Add("Collected: $($now.ToString('yyyy-MM-dd HH:mm:ss zzz'))")
$profile.Add("Collector access: $(if ($isAdmin) { 'Administrator' } else { 'Standard user; some sections may be partial' })")
$profile.Add('Privacy: filtered; secrets, unique hardware identifiers, network addresses, and user content are excluded.')
$profile.Add('')
$profile.Add('## System')
$profile.Add('')
$pcName = if ($computerProduct.ProductName) { "$($computerProduct.Vendor) $($computerProduct.ProductName) (type $($computerProduct.ProductCode))" } else { "$($computerSystem.Manufacturer) $($computerSystem.Model)" }
$profile.Add("- PC: $pcName")
$profile.Add("- Windows: $($os.Caption), version $($os.Version), build $($os.BuildNumber), $($os.Architecture)")
$profile.Add("- Last boot: $($os.LastBoot) ($($os.UptimeDays) days uptime)")
$profile.Add("- BIOS: $($bios.Manufacturer) $($bios.Version), released $($bios.ReleaseDate)")
$profile.Add("- Mainboard: $($baseboard.Manufacturer) $($baseboard.Product)")
$profile.Add("- CPU: $cpuSummary")
$profile.Add("- Memory: $memoryTotal GB across $($memory.Count) module(s)")
$profile.Add("- Graphics: $gpuSummary")
$displayMode = if ($gpus.Count -and $gpus[0].CurrentMode) { $gpus[0].CurrentMode -replace ' x \d+ colors$', '' } else { 'Unavailable' }
$profile.Add("- Current display mode: $displayMode")
$profile.Add("- Storage: $diskSummary")
$profile.Add("- Battery snapshot: $(if ($batteries.Count) { "$($batteries[0].EstimatedChargeRemaining)% charge, status $($batteries[0].Status)" } else { 'No battery reported' })")
$profile.Add("- Physical network: $(if ($networkAdapters.Count) { ($networkAdapters | ForEach-Object { "$($_.Description), $($_.Status), $($_.LinkSpeed)" }) -join '; ' } else { 'Unavailable' })")
$profile.Add("- Active power scheme: $powerScheme")
$profile.Add('')
$profile.Add('## Security snapshot')
$profile.Add('')
$profile.Add("- Secure Boot: $(if ($secureBoot -eq $true) { 'Enabled' } elseif ($secureBoot -eq $false) { 'Disabled' } else { 'Unavailable' })")
$profile.Add("- TPM: $(if ($tpm) { "Version $($tpm.TpmVersion), present $($tpm.TpmPresent), ready $($tpm.TpmReady), initialized $($tpm.TpmInitialized), vulnerable firmware reported $($tpm.VulnerableFirmwareReported)" } else { 'Unavailable' })")
$profile.Add("- Windows Firewall profiles enabled: $(@($firewall | Where-Object Enabled).Count) of $($firewall.Count)")
$antivirusRegistration = if ($securityCenterProducts.Count) { ($securityCenterProducts.Name -join ', ') } elseif ($securityCenterQuerySucceeded) { 'None registered' } else { 'Unavailable' }
$profile.Add("- Security Center antivirus registration: $antivirusRegistration")
$defenderStateText = if ($defenderIntentionallyAbsent) { 'Intentionally absent; orphan MDCoreSvc is stopped and disabled' } elseif ($defender) { "Real-time protection $($defender.RealTimeProtectionEnabled), signatures $($defender.AntivirusSignatureVersion)" } else { 'Unavailable in this session' }
$profile.Add("- Microsoft Defender Antivirus: $defenderStateText")
$profile.Add("- BitLocker/device encryption: $(if ($bitLocker.Count) { ($bitLocker | ForEach-Object { "$($_.MountPoint) $($_.ProtectionStatus), $($_.VolumeStatus)" }) -join '; ' } else { 'Unavailable in this session' })")
$profile.Add("- User Account Control: $(if ($uac.Enabled) { 'Enabled' } else { 'Disabled' }); secure-desktop prompt $(if ($uac.SecureDesktopPrompt) { 'enabled' } else { 'disabled' })")
$profile.Add('')
$profile.Add('## Capacity and health flags')
$profile.Add('')
if ($lowSpaceVolumes.Count) {
    foreach ($volume in $lowSpaceVolumes) { $profile.Add("- Low free space: $($volume.Drive) has $($volume.FreeGB) GB free ($($volume.FreePercent)%).") }
} else { $profile.Add('- No mounted drive is below 15% free space in this snapshot.') }
if ($problemDevices.Count) {
    foreach ($device in $problemDevices | Select-Object -First 20) { $profile.Add("- Device needs review: [$($device.Class)] $($device.FriendlyName) - status $($device.Status), problem $($device.Problem).") }
} else { $profile.Add('- No present Plug and Play device reported a problem in this snapshot.') }
if ($securityGaps.Count) { foreach ($gap in $securityGaps) { $profile.Add("- Security review: $gap") } } else { $profile.Add('- Defender, firewall, Secure Boot, TPM, and BitLocker returned no obvious summary-level gap.') }
if ($pendingReboot.ComponentServicing -or $pendingReboot.WindowsUpdate -or $pendingReboot.PendingFileRename) { $profile.Add('- Windows reports a pending restart condition.') } else { $profile.Add('- No common pending-restart marker was found.') }
$profile.Add('')
$profile.Add('## Inventory counts')
$profile.Add('')
$profile.Add("- Desktop application/installer records: $($desktopApps.Count)")
$profile.Add("- Current-user Store application packages: $($storeApps.Count)")
$profile.Add("- Present hardware devices: $($devices.Count)")
$profile.Add("- Signed driver records: $($drivers.Count)")
$profile.Add("- Services: $($services.Count)")
$profile.Add("- Startup entries: $($startupApps.Count)")
$profile.Add("- Startup names: $(if ($startupApps.Count) { ($startupApps.Name -join ', ') } else { 'None reported' })")
$optionalFeatureCount = if ($null -eq $optionalFeatureSource) { 'Unavailable (administrator scan required)' } else { $optionalFeatures.Count }
$profile.Add("- Enabled optional Windows features: $optionalFeatureCount")
$profile.Add("- Optional-feature inventory source: $(if ($optionalFeatureSource) { $optionalFeatureSource } else { 'Unavailable' })")
$profile.Add("- System critical/error event groups in the last 7 days: $($recentCriticalEvents.Count)")
$profile.Add('')
$profile.Add('## Collection limits')
$profile.Add('')
if ($warnings.Count) {
    foreach ($warning in $warnings) { $profile.Add("- $($warning.Section): $($warning.Message)") }
} else { $profile.Add('- All requested sections completed without a captured collection error.') }
$profile.Add('')
$profile.Add('## Detailed local evidence')
$profile.Add('')
$profile.Add('- `raw/inventory.json`: structured full snapshot')
$profile.Add('- `raw/desktop-apps.csv` and `raw/store-apps.csv`: installed application tables')
$profile.Add('- `raw/hardware-devices.csv` and `raw/drivers.csv`: device and driver tables')
$profile.Add('- `raw/services.csv`: service state and startup mode')

$profilePath = Join-Path $outputDirectory 'PC_PROFILE.md'
$profile | Set-Content -LiteralPath $profilePath -Encoding utf8

[pscustomobject]@{
    Status = 'COMPLETE'
    Profile = $profilePath
    Inventory = $inventoryPath
    IsAdministrator = $isAdmin
    WarningCount = $warnings.Count
    DesktopAppCount = $desktopApps.Count
    StoreAppCount = $storeApps.Count
    HardwareDeviceCount = $devices.Count
} | Format-List
