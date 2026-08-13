---
name: windows-11-maintain
description: Maintain Windows 11 with Windows Update, Storage Sense, DISM, SFC, CHKDSK, and supported backups. Use for cleanup, component-store repair, disk health, pending reboots, feature updates as maintenance, or /windows-11-maintain. Scan before repair. On this PC, DISM RestoreHealth and SFC need explicit acceptance that removed Defender files may return.
---

# Windows 11 maintain

Load `windows-pc-helper`. Read `windows-pc-helper/references/sources.md` for servicing facts. Propose every repair; act only after approval.

## Windows Update

1. Settings > Windows Update: status, last successful time, pause state, optional updates.
2. `Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 15`
3. Pending reboot (inventory already checks these):

   ```powershell
   Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'
   Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
   ```

4. Install the current monthly cumulative (B) from Windows Update. For a specific KB only, Microsoft Update Catalog — not third-party “update tuners.”
5. 24H2 → 25H2: enablement package after the device is current on 24H2. See `windows-11-operate`. Do not install 26H1 onto this class of PC.
6. If Learn release-health shows this edition/version is near or past end of updates, the supported hop from 24H2 is 25H2. Confirm dates in `windows-pc-helper/references/sources.md` before stating them.
7. Never uninstall or hide a quality update without a documented regression and a rollback plan.

## Storage

Order:

1. Settings > System > Storage: category breakdown. Confirm free space (this PC last showed ~83% free on C:).
2. Storage Sense (`ms-settings:storagepolicies`): temporary files, Recycle Bin, Downloads only if the user accepts that rule, cloud-file dehydration only if they use Files On-Demand.
3. Delivery Optimization cache: Settings > Windows Update > Advanced > Delivery Optimization > Advanced.
4. `DISM /Online /Cleanup-Image /AnalyzeComponentStore` then `/StartComponentCleanup` if reclaimable packages are large. Add `/ResetBase` only when the user accepts they cannot uninstall already-installed updates.
5. Empty Recycle Bin / user Downloads only with confirmation. Do not delete WinSxS, Prefetch, or installer folders by hand.

Do not run CCleaner or WinSxS-deleting scripts.

## Image integrity (DISM / SFC)

Use native `%SystemRoot%\System32\Dism.exe`. On this PC the PowerShell DISM provider can return `Class not registered`; that is not image damage.

**On this PC:** `/RestoreHealth` and `sfc /scannow` can restore deliberately removed Defender payloads. The component store already reports **repairable**. Do not repair “because CheckHealth said repairable” unless there is a matching user-visible servicing failure **and** the user accepts Defender may return.

Approved sequence when those conditions are met:

1. `Dism.exe /Online /Cleanup-Image /CheckHealth` — reads the corruption flag.
2. `Dism.exe /Online /Cleanup-Image /ScanHealth` — actual scan (slow).
3. Only if repairable **and** approved: `Dism.exe /Online /Cleanup-Image /RestoreHealth` (optional `/Source:` matching the same build, `/LimitAccess` to avoid Windows Update).
4. Then `sfc /scannow`.
5. Restart if prompted. Re-run SFC to confirm.

Watch `C:\Windows\Logs\CBS\CBS.log` if RestoreHealth appears stuck (often still working).

## Disk health

1. `Get-PhysicalDisk` / `Get-Volume` — Healthy vs Warning/Unhealthy.
2. `chkdsk C: /scan` (online, read-mostly).
3. `chkdsk C: /f` only after `/scan` (or volume health) shows errors; schedule on next boot; confirm backup first.
4. `chkdsk C: /r` only for suspected bad sectors; long offline. Last resort before replacement.

Never format or shrink/extend partitions without a backup confirmation and an explicit target.

## Backup and restore points

Before disk repair, feature updates, or firmware:

- Confirm the user has a backup they trust (File History, vendor recovery, or another copy). Do not invent a backup.
- System Restore: create a restore point only with approval; it is not a substitute for user-data backup.
- Do not enable BitLocker as a “maintenance” step — that is `windows-11-security` and needs recovery-key planning.

## Verify

Re-check Update history, disk free space, `Get-PhysicalDisk`, pending-reboot flags, and the original symptom. Record the result in the session notes; inventory files stay local.
