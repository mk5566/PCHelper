---
name: windows-11-maintain
description: Maintain Windows 11 with Windows Update, storage optimization (Storage Sense, Temporary files), DISM, SFC, CHKDSK, and supported backups. Use for cleanup, free up disk space, component-store repair, disk health, pending reboots, feature updates as maintenance, or /windows-11-maintain. Scan before repair. On this PC, DISM RestoreHealth and SFC need explicit acceptance that removed Defender files may return.
---

# Windows 11 maintain

Load `windows-pc-helper`. Read `../windows-pc-helper/references/sources.md` for servicing facts. User-facing clicks follow `../windows-pc-helper/references/visual-guidance.md`. DISM, SFC, CHKDSK `/f`/`/r`, optional features, and component cleanup follow `../windows-pc-helper/references/non-destructive-change.md` with a recovery method that actually applies to the named change. Propose every repair; act only after approval. Never call RestoreHealth or `chkdsk /r` “safe.”

## Windows Update

1. Settings > **Windows Update** (`ms-settings:windowsupdate`). Left nav last item highlighted. Main pane: status sentence (“You’re up to date” or a pending KB name), last-checked time, **Check for updates**, **Pause for 1 week**. **More options**: Update history, Advanced options (optional updates, Delivery Optimization, active hours).
2. `Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 15`
3. Pending reboot (inventory already checks these):

   ```powershell
   Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'
   Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
   ```

4. Install the current monthly cumulative (B) from Windows Update. For a specific KB only, Microsoft Update Catalog — not third-party “update tuners.”
5. 24H2 → 25H2: enablement package after the device is current on 24H2. See `windows-11-operate`. Do not install 26H1 onto this class of PC.
6. If Learn release-health shows this edition/version is near or past end of updates, the supported hop from 24H2 is 25H2. Confirm dates in `../windows-pc-helper/references/sources.md` before stating them.
7. Never uninstall or hide a quality update without a documented regression and a rollback plan.

## Storage

Order:

1. Settings > System > **Storage** (`ms-settings:storagesense`). Title **Storage**. Top: **Local Disk (C:)** usage bar and free/total. Category rows (Installed apps, Temporary files, Other, …). This PC last showed ~83% free.
2. Open **Storage Sense** (`ms-settings:storagepolicies`). Toggle at top. Then: Cleanup of temporary files; Automatic User content cleanup; Recycle Bin / Downloads age dropdowns (Downloads only if the user accepts); locally available cloud content. **Run Storage Sense now** at the bottom.
3. Delivery Optimization cache: Settings > Windows Update > Advanced > Delivery Optimization > Advanced.
4. `DISM /Online /Cleanup-Image /AnalyzeComponentStore` first. Use `/StartComponentCleanup` only when cleanup is recommended and the user accepts that superseded component versions are deleted immediately rather than after the normal grace period. Add `/ResetBase` only when the user accepts that all currently installed update packages become non-uninstallable.
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

Follow `../windows-pc-helper/references/non-destructive-change.md`. Before disk repair or a feature update, confirm the applicable recovery path and a user-data backup the user already has (do not invent one). Create a System Restore point when it can meaningfully protect Windows system state; it is not a document backup and cannot roll back firmware. Firmware belongs to `windows-11-hardware` and requires the OEM recovery procedure. Do not offer **Reset this PC** (Settings > System > Recovery) as cleanup. Do not enable BitLocker as maintenance (`windows-11-security`).

## Verify

Re-check Update history, disk free space, `Get-PhysicalDisk`, pending-reboot flags, and the original symptom. Record the result in the session notes; inventory files stay local.
