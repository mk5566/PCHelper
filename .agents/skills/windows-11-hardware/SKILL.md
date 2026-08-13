---
name: windows-11-hardware
description: Diagnose and update x86/x64 Windows 11 hardware: drivers, firmware, CPU/GPU/storage/memory, and platform features (TPM, Secure Boot capable firmware, Thread Director, Intel Arc). Use for Device Manager problems, driver updates, BIOS, GPU installs, disk health beyond capacity, compatibility, or /windows-11-hardware. Prefer Windows Update, the PC OEM, then the component vendor. Never use driver-updater packs.
---

# Windows 11 hardware (x86/x64)

Load `windows-pc-helper`. Read `windows-pc-helper/references/reject-unproven.md` before any driver recommendation.

## This machine (inventory 2026-08-13)

| Part | Identity | Driver / firmware notes |
|---|---|---|
| System | Lenovo IdeaPad Slim 5 16IMH9 (83DC) | BIOS N7CN35WW, 2025-12-16 |
| CPU | Intel Core Ultra 7 155H (16c / 22t) | Windows 11 scheduler + Thread Director; do not park E-cores with third-party tools |
| GPU | Intel Arc (iGPU) | Driver 32.0.101.8861 (2026-07-05). Intel Graphics Software is installed |
| NPU | Intel AI Boost | Present; leave unless a named failure exists |
| Storage | WD SN740 1 TB NVMe | `Healthy`; Standard NVM Express Controller |
| Wi-Fi | Intel AX211 160 MHz | Driver 24.60.0.3 (2026-06-11). Physical adapter OK; Wi-Fi Direct virtual adapter has NDIS 10317 history |
| Memory | 16 GB (2×8 GB Samsung, ~7467 MT/s) | Soldered-class LPDDR; no user DIMM upgrade path implied |
| Display | 1920×1200 + external BenQ / LG HDR 4K seen | |

Refresh inventory after any driver or BIOS change.

## Driver source order

1. **Windows Update** optional driver if it matches the device and the user wants Microsoft-distributed.
2. **PC OEM** (here: Lenovo Support for 83DC / IdeaPad Slim 5 16IMH9) for BIOS, EC, chipset, and laptop-specific power/hotkey/audio.
3. **Component vendor** for GPU, Wi-Fi, storage when OEM is behind or the issue is IHV-specific: Intel (Arc, AX211, chipset), Western Digital / SanDisk for the SN740.
4. **Microsoft Update Catalog** for a *specific* WHCP-signed KB the user or a diagnostic named.

Never: Driver Booster, Snappy Driver Installer packs, “driver pack” ISOs, third-party BIOS hosts, or Device Manager “update driver” that pulls an older generic.

Prefer WHCP-signed packages ([Windows Hardware Compatibility Program](https://learn.microsoft.com/en-us/windows-hardware/design/compatibility/)). Inbox Microsoft drivers are acceptable when they work; OEM/IHV only when they fix a named defect or add a required feature.

## Procedure

1. `Get-PnpDevice -PresentOnly | Where-Object { $_.Status -ne 'OK' -or ($_.Problem -and $_.Problem -ne 0) }`
2. `Get-CimInstance Win32_PnPSignedDriver` for the device class — record version and date, not INF hunting in chat.
3. Identify the hardware ID in Device Manager only as far as needed to pick the OEM/IHV package. Do not store serials.
4. Propose **one** package: name, version, source URL (official), what it replaces, restart, how to roll back (Device Manager Roll Back, or OEM previous version).
5. After approval, install that package only. Verify: device Status OK, same or newer signed version, symptom gone, no new Reliability Monitor criticals.

Firmware (BIOS/EC): OEM instructions, charged battery + AC, no power loss. Confirm current `N7CN35WW` vs Lenovo’s published latest at execution time. Do not flash a “modded” BIOS.

## CPU / GPU / memory / storage specifics

- **Intel Core Ultra:** hybrid P/E/LPE cores. Leave Windows 11 power mode and scheduling alone unless diagnosing a stuck-on-E-core bug with ETW. Virtualization firmware (`VirtualizationFirmwareEnabled`) false in inventory is not by itself a defect; VBS may still run.
- **Intel Arc iGPU:** use Intel’s Windows 11 DCH package or Lenovo’s wrapped build. HAGS only if Settings shows the toggle (`windows-11-optimize`). DirectX 12 / WDDM 2.0 is the Windows 11 floor; this GPU exceeds it.
- **WD SN740:** `Get-PhysicalDisk` health first. Vendor dashboard only if SMART details are required. TRIM is periodic on NTFS SSDs; do not run weekly “optimize” rituals.
- **RAM:** 16 GB is the Windows 11 minimum×4; treat commit-limit symptoms as app/working-set issues first (`windows-11-optimize`), not a forced pagefile hack. Do not run MemTest without unexplained bugchecks or failed memory diagnostics.
- **AX211:** update from Intel/Lenovo only if user-visible Wi-Fi fails. Ignore isolated Wi-Fi Direct 10317 events.

## Compatibility

- Windows 11 CPU lists live on Learn ([processor requirements](https://learn.microsoft.com/en-us/windows-hardware/design/minimum/windows-processor-requirements)). This 155H is a current-generation Intel mobile part; do not apply Windows 10-era “unsupported CPU” advice.
- Discrete GPU + iGPU: bind apps in Settings > System > Display > Graphics.
- USB4 / Thunderbolt / external GPU: OEM firmware first.
- Do not recommend x86-to-ARM tricks; this skill is x86/x64. 26H1 (build 28000) is a new-silicon train, not a driver update for this laptop.

## Rollback

Device Manager > device > Properties > Driver > Roll Back Driver. If greyed out, reinstall the previously known-good OEM/IHV version. Keep the installer the user approved.
