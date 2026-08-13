# Windows built-in tool map

## Selection table

| Need | Start with | Escalate carefully to | Notes |
|---|---|---|---|
| OS and hardware baseline | CIM (`Win32_*`), `Get-ComputerInfo`, `Get-PnpDevice` | Manufacturer diagnostics | Omit serials and unique IDs. Identify version by build: 26100=24H2, 26200=25H2, 28000=26H1. |
| CPU, memory, and live load | Task Manager, Resource Monitor, `Get-Counter`, CIM | Windows Performance Recorder/Analyzer | Capture only the duration needed; traces may contain paths. Efficiency Mode is EcoQoS, not a RAM free. |
| Storage capacity and health | Settings > System > Storage, Storage Sense, `Get-PhysicalDisk`, `Get-Volume` | `chkdsk /scan`, then `chkdsk /f` only with approval | Never run `/r`, format, or partition commands without approval and backup confirmation. |
| Windows component integrity | Event logs, CBS.log tail, servicing state | Native `Dism.exe /Online /Cleanup-Image /CheckHealth` then `/ScanHealth`; `/RestoreHealth` and `sfc /scannow` only with approval | `/CheckHealth` reads a flag; `/ScanHealth` scans. Repair can restore intentionally removed Defender files on this PC. Prefer native `Dism.exe` over the PowerShell DISM provider. |
| Drivers and devices | Device Manager, `Get-PnpDevice`, `Win32_PnPSignedDriver`, Windows Update optional updates | PC OEM then GPU/NIC/storage vendor support | Avoid generic driver-updater utilities and unofficial download sites. Prefer WHCP-signed packages. |
| Windows Update | Settings > Windows Update, update history, `Get-HotFix`, `wuauserv` | Microsoft Update Catalog for a specific KB | Do not hide or uninstall updates without a diagnosed reason. 25H2 is an enablement package on 24H2. 26H1 is not an in-place upgrade from 24H2/25H2. |
| Security | Windows Security, firewall profiles, TPM (`Get-Tpm` / `tpmtool`), Secure Boot, BitLocker status | Microsoft security guidance | Never display keys or disable protection as a diagnostic shortcut. On this PC, Defender absence is intentional. |
| Startup and background load | Settings > Apps > Startup, Task Manager Startup, `Win32_StartupCommand` | Individual service start-type change only with a named dependency check | Disabling a service can break dependencies; propose exact targets first. |
| Networking | Settings network troubleshooter, `Get-NetAdapter`, `Get-NetIPConfiguration`, `Test-NetConnection` | `netsh trace`, packet capture | Do not record Wi-Fi keys, MACs, IPs, DNS suffixes, or full captures by default. Do not reset Winsock/TCP as a first step. |
| Battery and power | Settings > System > Power & battery (Power mode, Energy saver), `powercfg /getactivescheme`, `powercfg /batteryreport`, `powercfg /sleepstudy` | OEM battery/firmware diagnostics | Power *mode* is the Windows 11 control. Classic High Performance / Ultimate Performance plans are the wrong first lever on Modern Standby laptops. Reports stay local and gitignored. |
| Crashes and hangs | Reliability Monitor (`perfmon /rel`), Event Viewer System/Application, `Get-WinEvent` | Focused dump or WinDbg | Dumps can contain private data; ask before capturing or opening them. |
| Installed applications | Settings Apps, uninstall registry inventory, `Get-AppxPackage`, `winget list` | Publisher-supported inventory | Do not execute uninstall strings from the registry. |
| App repair | App settings Repair/Reset, package-specific logs | Reinstall from official source | Reset may erase app-local state; state the effect first. |
| Virtualization and Linux | Windows Features, `wsl --status`, `wsl -l -v`, `bcdedit /enum` hypervisorlaunchtype, Memory Integrity state | DISM feature changes, firmware virtualization | Feature changes usually require admin and restart. VBS/HVCI keep the hypervisor running even if Hyper-V is not installed. |

## Administrator boundary

A non-administrator session can collect most baseline facts. BitLocker, TPM, Secure Boot, optional features, protected event channels, system repairs, driver changes, and service configuration may return partial or access-denied results. Record that limitation. Ask for an administrator session only when the missing evidence is material.

## Repair prerequisites

Before a medium- or high-impact repair:

1. Identify the exact symptom and evidence supporting the repair.
2. Confirm backups or another recovery path when user data or bootability could be affected.
3. Capture the current setting/version/state.
4. Prefer a reversible change and describe how to undo it.
5. Define the success check before acting.
6. Record the result, including whether restart is pending.
