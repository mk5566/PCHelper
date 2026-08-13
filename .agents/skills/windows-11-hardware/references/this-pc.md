# This PC hardware snapshot

From inventory **2026-08-13**. Refresh `../../../../inventory/PC_PROFILE.md` after any driver or BIOS change. The inventory folder is local and intentionally absent from a clean clone. Do not treat this table as live.

| Part | Identity | Notes |
|---|---|---|
| System | Lenovo IdeaPad Slim 5 16IMH9 (83DC) | BIOS N7CN35WW, 2025-12-16 |
| CPU | Intel Core Ultra 7 155H (16c / 22t) | Windows 11 scheduler + Thread Director; do not park E-cores with third-party tools |
| GPU | Intel Arc (iGPU) | Driver 32.0.101.8861 (2026-07-05). Intel Graphics Software is installed. HAGS only if Settings shows the toggle |
| NPU | Intel AI Boost | Leave unless a named failure exists |
| Storage | WD SN740 1 TB NVMe | `Healthy`; Standard NVM Express Controller. TRIM is periodic on NTFS; no weekly optimize ritual |
| Wi-Fi | Intel AX211 160 MHz | Driver 24.60.0.3 (2026-06-11). Isolated NDIS 10317 on the Wi-Fi Direct *virtual* adapter is not proof the user Wi-Fi is broken |
| Memory | 16 GB (2×8 GB Samsung, ~7467 MT/s) | Soldered-class LPDDR. Commit-limit issues are app/working-set first, not a pagefile hack |
| Display | 1920×1200 + external BenQ / LG HDR 4K seen | Bind apps in Settings > System > Display > Graphics if a dGPU is added |

Driver sources for this chassis: Lenovo Support for 83DC (BIOS/EC/chipset/hotkey/audio); Intel for Arc and AX211; WD/SanDisk for the SN740. Confirm current BIOS vs Lenovo’s published latest at execution time.

16 GB is four times the Windows 11 *minimum* (4 GB on Learn), not a requirement. This 155H is a current-generation Intel mobile part — do not apply Windows 10-era “unsupported CPU” advice. 26H1 (build 28000) is a new-silicon train, not a driver update for this laptop.
