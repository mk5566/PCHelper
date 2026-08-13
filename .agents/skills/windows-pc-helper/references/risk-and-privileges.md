# Risk level and privileges

State **risk**, **required privileges**, and restart expectation once for each read-only inspection batch and separately for every proposed or executed persistent change. Never label High or Destructive work as safe.

## Privileges

| Label | Meaning |
|---|---|
| Standard | Current user; no UAC. |
| Admin | Elevated (UAC Yes). Many CIM/DISM/service/driver commands fail without it — that is access denied, not “feature absent.” |
| Firmware | UEFI/BIOS setup; not Windows. |
| Restart | Change applies only after reboot (or the next boot for `chkdsk /f`). Say so up front. |

## Risk

| Level | Meaning | Examples | Restore point? |
|---|---|---|---|
| None | Read-only; no persistent change | Inventory, Task Manager, Reliability Monitor, Event Viewer, `Get-*`, Settings pages viewed but not changed | No |
| Low | Reversible per-user or documented control with limited scope | Power mode, Energy saver, startup-app toggle, Game Mode, privacy app-permission toggle, `chkdsk /scan` | No; capture current state and written undo |
| Medium | Machine-wide, deletes selected data, or servicing-adjacent; can affect other apps or need restart | Storage Sense cleanup after reviewing categories, optional Windows Update driver, WinGet/app uninstall, HAGS, Memory Integrity, optional features, Fast Startup | Applicable rollback; restore point when it materially covers the change |
| High | System files, services, BCD, disk repair, encryption, AV, or firmware | DISM `/RestoreHealth`, `sfc /scannow`, `chkdsk /f` or `/r`, service start-type, BCD, BitLocker, BIOS/UEFI update | Required applicable recovery path (`non-destructive-change.md`); firmware uses OEM recovery, not System Restore |
| Destructive | The intended operation deletes data or reinstalls/repartitions the system | Reset this PC, format, delete/recreate partitions, recovery-drive wipe | User-data backup **and** explicit acceptance; not a “tweak” |

On this PC, DISM RestoreHealth / SFC is **High** and may restore Defender. BitLocker enable is **High** and needs a recovery-key plan first.

## How to surface it

For a read-only inspection batch and for each recommended or executed persistent change, write one line:

`Risk: <None|Low|Medium|High|Destructive> · Privilege: <Standard|Admin|Firmware> · Restart: <No|Yes>`

If any item is High or Destructive, stop for approval before acting.
