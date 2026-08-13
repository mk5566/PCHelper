---
name: windows-11-hardware
description: Diagnose and update x86/x64 Windows 11 hardware: drivers, firmware, CPU/GPU/storage/memory, and platform features (TPM, Secure Boot capable firmware, Thread Director, Intel Arc). Use for Device Manager problems, driver updates, BIOS, GPU installs, disk health beyond capacity, compatibility, or /windows-11-hardware. Prefer Windows Update, the PC OEM, then the component vendor. Never use driver-updater packs.
---

# Windows 11 hardware (x86/x64)

Load `windows-pc-helper`. Read `../windows-pc-helper/references/reject-unproven.md` before any driver recommendation. This machine’s snapshot: `references/this-pc.md` (or a fresh `../../../inventory/PC_PROFILE.md`). UI: `../windows-pc-helper/references/visual-guidance.md`. Risk: `../windows-pc-helper/references/risk-and-privileges.md`. Driver and firmware installs: `../windows-pc-helper/references/non-destructive-change.md`. Never call a BIOS flash “safe,” and never present System Restore as firmware rollback.

## Driver source order

1. **Windows Update** optional driver: Settings > Windows Update > **Advanced options** > **Optional updates** > **Driver updates**. One named package only. `Risk: Medium` · `Privilege: Admin` · `Restart: often`.
2. **PC OEM** (Lenovo 83DC on this laptop) for BIOS, EC, chipset, hotkey, audio.
3. **Component vendor** (Intel / WD) when OEM is behind or the defect is IHV-specific.
4. **Microsoft Update Catalog** only for a specific package selected by device identity, supported Windows version, publisher, driver version, and signature. Catalog driver entries are not necessarily identified by a KB number.

Never: Driver Booster, Snappy Driver Installer packs, third-party BIOS hosts, or Device Manager “update” that pulls an older generic. Prefer properly signed drivers distributed through Windows Update or an official OEM/component-vendor channel; use [WHCP](https://learn.microsoft.com/en-us/windows-hardware/design/compatibility/) information when certification evidence is relevant.

## Procedure

1. `Get-PnpDevice -PresentOnly` for non-OK / problem codes.
2. `Win32_PnPSignedDriver` for version and date of that class — not INF hunting in chat.
3. Device Manager (`devmgmt.msc`): class tree, yellow bang, Properties → **General** + **Driver** (Update / **Roll Back** / Uninstall). Hardware Ids on Details only to pick the package. No serials.
4. Propose **one** official package: name, version, URL, what it replaces, restart, rollback.
5. After approval, install that package only. Verify Status OK, version, symptom, Reliability Monitor.

Firmware: use the OEM procedure, charged battery + AC, and confirm the installed version against the vendor's current release at execution time. Establish the OEM-supported BIOS recovery or rollback path first; a Windows restore point cannot revert firmware. `Risk: High` · `Privilege: Firmware` · `Restart: Yes`.

## Compatibility

CPU lists: [processor requirements](https://learn.microsoft.com/en-us/windows-hardware/design/minimum/windows-processor-requirements). Do not invent requirements. This skill is x86/x64 only. Device-specific notes stay in `references/this-pc.md`.

## Rollback

Device Manager → Properties → **Driver** → **Roll Back Driver**. If greyed out, reinstall the last known-good OEM/IHV package. System Restore is the fallback.
