# Risk level and privileges

State **risk** and **required privileges** on every action, including “just look.” Do not skip this for Settings toggles. Never label High or Destructive work as safe.

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
| Low | Reversible per-user or documented Settings control; unrelated apps/security/hardware stay intact | Power mode, Energy saver, startup-app toggle, Game Mode, Storage Sense run, privacy app-permission toggle | No (written undo is enough) |
| Medium | Machine-wide or servicing-adjacent; can affect other apps or need restart | Optional Windows Update driver, WinGet/app uninstall, HAGS, Memory Integrity, optional features, Fast Startup, `chkdsk /scan` | Yes if it touches drivers/features; otherwise confirm undo path |
| High | System files, services, BCD, disk repair, encryption, AV | DISM `/RestoreHealth`, `sfc /scannow`, `chkdsk /f` or `/r`, service start-type, BCD, BitLocker, firmware | Required (`non-destructive-change.md`) |
| Destructive | Data or install can be lost | Reset this PC, format/partition, recovery-drive wipe, BIOS flash fail | User-data backup **and** explicit acceptance; not a “tweak” |

On this PC, DISM RestoreHealth / SFC is **High** and may restore Defender. BitLocker enable is **High** and needs a recovery-key plan first.

## How to surface it

For each recommended or executed step, write one line:

`Risk: <None|Low|Medium|High|Destructive> · Privilege: <Standard|Admin|Firmware> · Restart: <No|Yes>`

If any item is High or Destructive, stop for approval before acting.
