---
name: windows-11-operate
description: Operate Windows 11 correctly across Home, Pro, Pro Education, Pro for Workstations, Enterprise, Education, SE, and LTSC. Covers Settings vs Control Panel, feature updates (24H2, 25H2 enablement package, 26H1 new-silicon only), accounts, display, and daily configuration. Use when the user asks how to use Windows 11, which edition they have, whether to take 25H2/26H1, or runs /windows-11-operate.
---

# Windows 11 operate

Load `windows-pc-helper` first. Read `windows-pc-helper/references/sources.md` before stating version or edition facts. Re-fetch Learn release-health if the claim is date-sensitive.

## Identify the device

```powershell
Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion, OsBuildNumber, OsArchitecture, CsPCSystemType
(Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').DisplayVersion
```

| Build family | Version | Notes |
|---|---|---|
| 26100 | 24H2 | Current GAC + LTSC 2024 base. This PC’s 2026-08-13 inventory. |
| 26200 | 25H2 | Same servicing train as 24H2; switched on by enablement package KB5054156. |
| 28000 | 26H1 | **New devices only.** Not offered as an in-place update from 24H2 or 25H2. Do not tell a 24H2/25H2 user to “upgrade to 26H1”. |
| 22631 | 23H2 | Home/Pro already past end of updates. Enterprise/Education date: `sources.md`. |

Edition capabilities (do not invent others):

- **Home:** Settings and built-in tools only. No Client Hyper-V, no BitLocker To Go, no gpedit/RDP *host*. OOBE needs internet + Microsoft account.
- **Pro / Pro Education / Pro for Workstations:** Group Policy, Hyper-V (SLAT), BitLocker To Go, RDP host.
- **Enterprise / Education:** 36-month feature-update support; hotpatch possible on 24H2/25H2 Enterprise.
- **SE:** last supported feature version is 24H2.
- **Enterprise LTSC 2024:** 24H2 only; no 25H2 enablement path.

S mode exists only on Home. Leaving S mode requires internet and is one-way.

## Feature updates

1. Confirm build and edition.
2. Check [Windows 11 release information](https://learn.microsoft.com/en-us/windows/release-health/windows11-release-information) and the version’s known-issues page for safeguard holds.
3. Prefer **Settings > Windows Update**. Unmanaged Home/Pro devices get 25H2 through the intelligent rollout; “Check for updates” may surface **Download and install Windows 11, version 25H2**.
4. 24H2 → 25H2 is a small enablement package and one restart once the 24H2 monthly baseline is current. Do not download a full ISO for that hop unless Windows Update cannot offer it.
5. Do not install 26H1 onto existing 24H2/25H2 PCs.
6. Do not use labconfig / `AllowUpgradesWithUnsupportedTPMOrCPU` / Rufus TPM bypass. Unsupported installs can lose future updates.

Pause updates only from Settings (max 35 days). Do not hide KBs without a named regression.

## Settings first

Use Settings (`ms-settings:`) for power, display, apps, accounts, Windows Update, storage, and privacy. Open a Control Panel applet only when Settings has no equivalent (some BitLocker, power-plan, and device-manager deep links).

Daily tasks:

- Display / scale / refresh: Settings > System > Display. HDR and Auto HDR need an HDR panel.
- Snap three-column layouts need ≥1920 effective pixels.
- Accounts: Settings > Accounts. Do not collect or store MSA details.
- Optional features / Windows capabilities: Settings > System > Optional features, or native `Dism.exe /Online /Get-Features`. Elevation required. Do not remove Print to PDF, WCF, .NET 4 Advanced Services, or Windows Search on this PC without naming the lost function.
- WSL: `wsl --status`. This PC does not have WSL; install only after approval (`wsl --install`).

## Configuration changes

Follow the `windows-pc-helper` change ladder. Prefer a Settings toggle the user can reverse. Do not ship `.reg` files for options that exist in Settings.
