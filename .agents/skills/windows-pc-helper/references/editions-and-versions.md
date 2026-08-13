# Editions and versions

Load only when identifying the OS or advising a feature update. Re-fetch [release information](https://learn.microsoft.com/en-us/windows/release-health/windows11-release-information) before stating end-of-update dates. Dated numbers: `sources.md`.

## Build families

| Build family | Version | Notes |
|---|---|---|
| 26100 | 24H2 | GAC + LTSC 2024 base. This PC’s 2026-08-13 inventory. |
| 26200 | 25H2 | Same servicing train as 24H2; enablement package KB5054156. |
| 28000 | 26H1 | New devices only. **Not** an in-place update from 24H2 or 25H2. |
| 22631 | 23H2 | Home/Pro past end of updates. Enterprise/Education date: `sources.md`. |

Identify:

```powershell
Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion, OsBuildNumber, OsArchitecture, CsPCSystemType
(Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').DisplayVersion
```

## Edition capabilities (do not invent others)

- **Home:** Settings and built-in tools. No Client Hyper-V, BitLocker To Go, gpedit, or RDP *host*. OOBE needs internet + Microsoft account. S mode exists only here; leaving it is one-way and needs internet.
- **Pro / Pro Education / Pro for Workstations:** Group Policy, Hyper-V (SLAT), BitLocker To Go, RDP host.
- **Enterprise / Education:** 36-month feature-update support; hotpatch possible on 24H2/25H2 Enterprise (not 26H1).
- **SE:** last supported feature version is 24H2.
- **Enterprise LTSC 2024:** 24H2 only; no 25H2 enablement path.

## Feature-update rules

- 24H2 → 25H2: enablement package, one restart, after the monthly 24H2 baseline is current. Prefer Settings > Windows Update, not a full ISO.
- Do not install 26H1 onto existing 24H2/25H2 PCs.
- Do not use labconfig, `AllowUpgradesWithUnsupportedTPMOrCPU`, or Rufus TPM bypass.
- Pause only from Settings (max five weeks). Do not hide KBs without a named regression.
