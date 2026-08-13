# Windows built-in tool map

## Selection table

| Need | Start with | Escalate carefully to | Notes |
|---|---|---|---|
| OS and hardware baseline | CIM (`Win32_*`), `Get-ComputerInfo`, `Get-PnpDevice` | Manufacturer diagnostics | Omit serials and unique IDs. |
| CPU, memory, and live load | Task Manager, Resource Monitor, `Get-Counter`, CIM | Windows Performance Recorder/Analyzer | Capture only the duration needed; traces may contain paths. |
| Storage capacity and health | `Get-PhysicalDisk`, `Get-Volume`, Storage Settings | `chkdsk /scan`, vendor SMART tool | Never run repair modes or format/partition commands without approval and backup confirmation. |
| Windows component integrity | Event logs and servicing state | `DISM /Online /Cleanup-Image /ScanHealth`, then `/RestoreHealth`; `sfc /scannow` | Scan modes first. Repair modes need approval and may require restart. |
| Drivers and devices | Device Manager, `Get-PnpDevice`, `Win32_PnPSignedDriver`, Windows Update | PC/component vendor support | Avoid generic driver-updater utilities and unofficial download sites. |
| Windows Update | Settings, update history, `Get-HotFix`, Windows Update service | Microsoft Update Catalog for a specific KB | Do not hide or uninstall updates without a diagnosed reason. |
| Security | Windows Security, `Get-MpComputerStatus`, firewall profiles, TPM, Secure Boot, BitLocker status | Microsoft security guidance | Never display keys or disable protection as a diagnostic shortcut. |
| Startup and background load | Task Manager Startup Apps, `Win32_StartupCommand`, services | Autoruns only if built-in evidence is insufficient | Disabling a service can break dependencies; propose exact targets first. |
| Networking | Windows troubleshooter, `Get-NetAdapter`, `Get-NetIPConfiguration`, `Test-NetConnection` | `netsh trace`, packet capture | Do not record Wi-Fi keys, MACs, IPs, DNS suffixes, or full captures by default. |
| Battery and power | Settings, `powercfg /getactivescheme`, `powercfg /batteryreport` | OEM battery diagnostics | Battery reports contain device and usage details; keep local and ignored by Git. |
| Crashes and hangs | Reliability Monitor, Event Viewer, Windows Error Reporting summary | Focused dump or trace | Dumps can contain private data; ask before capturing or opening them. |
| Installed applications | Settings Apps, uninstall registry inventory, `Get-AppxPackage`, `winget list` | Publisher-supported inventory | Do not execute uninstall strings from the registry. |
| App repair | App settings Repair/Reset, package-specific logs | Reinstall from official source | Reset may erase app-local state; state the effect first. |
| Virtualization and Linux | Windows Features, `wsl --status`, `wsl -l -v`, Hyper-V status | DISM feature changes | Feature changes usually require admin and restart. |

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
