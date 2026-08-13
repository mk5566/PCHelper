# Authoritative sources

Retrieved **2026-08-13**. Re-fetch before stating servicing dates, known issues, or processor lists as current. Prefer Microsoft Learn, Microsoft Support, Windows Hardware Compatibility Program, and the PC/CPU/GPU/NIC/storage vendor.

Do not invent hardware requirements, hidden switches, or unsupported configurations. If it is not on this page or a live re-fetch of these URLs, do not state it as a requirement or as a supported workaround.

## Servicing and editions

| Claim | Source | Date on page |
|---|---|---|
| Annual feature update; Home/Pro 24 months, Enterprise/Education 36 months; monthly cumulative B releases | [Windows 11 release information](https://learn.microsoft.com/en-us/windows/release-health/windows11-release-information) | 2026-08-11 |
| 25H2 build 26200.9168, 24H2 build 26100.9168, 23H2 build 22631.7517 (Home/Pro 23H2 end of updates); 2026-08 B is KB5121003 for 24H2/25H2 | Same | 2026-08-11 |
| 26H1 (build 28000) is for new early-2026 devices only; **not** an in-place update from 24H2 or 25H2; no hotpatch | Same | 2026-08-11 |
| 25H2 is an enablement package on 24H2; features stay dormant until the package; one restart | [KB5054156](https://support.microsoft.com/topic/kb5054156-feature-update-to-windows-11-version-25h2-by-using-an-enablement-package-4d307e2d-3028-4323-bb46-552cff491643) | 2025 |
| 24H2 Home/Pro end of updates 2026-10-13 | [24H2 known issues](https://learn.microsoft.com/en-us/windows/release-health/status-windows-11-24h2) | 2025-03-27 note; re-check |
| Hotpatch: Enterprise clients on 24H2/25H2; not 26H1 | Release information hotpatch calendar | 2026-08-11 |

This PC’s last inventory (2026-08-13) is **24H2, build 26100**, Windows 11 Home. Confirm with `Get-ComputerInfo` / `winver` before advising a feature update.

## Platform requirements

| Claim | Source | Date on page |
|---|---|---|
| 64-bit compatible CPU (2+ cores, 1 GHz+), 4 GB RAM, 64 GB storage, DirectX 12 + WDDM 2.0, UEFI Secure Boot capable, TPM 2.0, 720p 9"+ | [Windows 11 requirements](https://learn.microsoft.com/en-us/windows/whats-new/windows-11-requirements) | 2026-07-14 |
| Home OOBE requires internet + Microsoft account | Same | 2026-07-14 |
| Feature extras: BitLocker To Go and Client Hyper-V are Pro and above; DirectStorage needs NVMe + DX12 SM 6.0; Wi-Fi 6E needs IHV hardware + AP | Same | 2026-07-14 |
| VMs: Gen 2, vTPM, Secure Boot, 4 GB, 2 vCPU; host CPU generally must be on the supported list | Same | 2026-07-14 |
| TPM 2.0 not supported in Legacy/CSM BIOS; Native UEFI only | [TPM recommendations](https://learn.microsoft.com/en-us/windows/security/hardware-security/tpm/tpm-recommendations) | 2025-08-15 |
| Supported processor list (do not guess) | [Windows processor requirements](https://learn.microsoft.com/en-us/windows-hardware/design/minimum/windows-processor-requirements) | re-fetch |

## Integrity, storage, power, graphics, hardware

| Claim | Source |
|---|---|
| DISM `/ScanHealth` scans; `/CheckHealth` reports healthy / repairable / non-repairable; `/RestoreHealth` repairs, optional `/Source` and `/LimitAccess` | [Repair a Windows Image](https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/repair-a-windows-image?view=windows-11) |
| `sfc /scannow` scans protected files and replaces incorrect Microsoft versions | [System File Checker](https://learn.microsoft.com/en-us/troubleshoot/windows-server/installing-updates-features-roles/system-file-checker) |
| Storage Sense: Settings > System > Storage; temp files, user-content cleanup, cloud dehydration; cadence daily/weekly/monthly/low space | [Configure Storage Sense](https://learn.microsoft.com/en-us/windows/configuration/storage/storage-sense) |
| Power mode: Best power efficiency / Balanced / Best performance under Settings > System > Power & battery; Energy saver is separate | [Change the power mode](https://support.microsoft.com/windows/change-the-power-mode-for-your-windows-pc-c2aff038-22c9-f46d-5ca0-78696fdf2de8) |
| VBS and HVCI (Memory Integrity) on by default on capable new Windows 11 installs | [Silicon-assisted security](https://learn.microsoft.com/en-us/windows/security/book/hardware-security-silicon-assisted-security) |
| Third-party hypervisors conflict with Hyper-V, Memory Integrity, Credential Guard | [KB3204980](https://learn.microsoft.com/en-us/troubleshoot/windows-client/application-management/virtualization-apps-not-work-with-hyper-v) |
| WHCP: systems and drivers tested with HLK; look up certified products rather than unsigned packs | [WHCP](https://learn.microsoft.com/en-us/windows-hardware/design/compatibility/) |
| HAGS appears only when GPU + WDDM 2.7+ driver advertise it (Settings > System > Display > Graphics > default graphics settings) | Microsoft Q&A guidance consistent with WDDM 2.7 requirement; confirm on-device, do not force via registry |

## Recovery

| Claim | Source | Retrieved |
|---|---|---|
| System Restore reverts system files, registry, and installed programs to a restore point; not personal files | [System Restore](https://support.microsoft.com/windows/system-restore) | 2026-08-13 |
| Create a point: Start → “Create a restore point” → System Protection tab → Create… | [System Protection](https://support.microsoft.com/windows/system-protection) | 2026-08-13 |
| Reset this PC lives at Settings > System > Recovery; it is a reinstall, not a tweak rollback | [Reset your PC](https://support.microsoft.com/windows/reset-your-pc) | 2026-08-13 |

## Discarded as sources

Forum tweak lists, TenForums/ElevenForum registry packs (unless they only cite a Microsoft doc), YouTube “FPS boost”, OEM-blog copies of those lists, and any page that does not name a primary Microsoft or hardware-vendor document.
