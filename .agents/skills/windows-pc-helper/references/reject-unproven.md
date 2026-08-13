# Rejected advice (no proven net benefit or unsafe)

Do not recommend, run, or link to these. If the user asks for one, refuse the method and offer the built-in alternative.

## Always reject

| Category | Why | Use instead |
|---|---|---|
| Registry cleaners / “repair registry” apps | No Microsoft-supported benefit; high risk of breaking COM/file associations | `sfc` / DISM only after evidence of component-store or protected-file damage |
| RAM boosters, memory “optimizers”, Game Booster RAM free | They empty the working set; Windows re-reads the same pages. Apparent free RAM is not throughput | Task Manager to find the actual working-set owner |
| Third-party driver updater packs (Driver Booster, Snappy Driver Installer packs, “driver packs”) | Unsigned or mismatched drivers; no WHCP guarantee | Windows Update optional drivers, PC OEM, then Intel/AMD/NVIDIA/storage vendor |
| Debloat scripts, “Windows 11 optimizer” .bat/.reg packs, privacy packs that disable services en masse | Undocumented, irreversible, often break Store, Search, Update, or security | Change one named setting or startup app after measuring it |
| CCleaner-style multi-cleaners, temp wipers that touch Prefetch/WinSxS/installer cache blindly | Can break servicing and app repair | Storage Sense; Settings > Storage |
| Disable SysMain, Windows Search, Superfetch, or prefetch “for SSD speed” as generic advice | SysMain is prefetch/superfetch; disabling it is not an SSD requirement | Measure disk queue and the specific process first |
| Disable or delete the pagefile as an optimization | Causes commit-limit failures; does not make RAM faster | Leave system-managed unless a diagnosed commit problem exists |
| “Ultimate Performance” power plan, hidden High Performance plan, or `powercfg -duplicatescheme` on laptops | Bypasses Modern Standby / OEM power policy; heat and battery cost with little sustained gain | Settings > Power & battery > Power mode |
| Timer-resolution hacks, MMCSS tweaks, HPET on/off, BCD “tweaks”, disable Spectre/Meltdown mitigations for FPS | Unstable, security-regressing, or placebo | GPU driver + Power mode + close measured overlays |
| Disable Memory Integrity / VBS / Secure Boot / firewall / UAC as a performance or “fix” shortcut | Security regression; VBS cost is real but must be measured, not assumed | Confirm a specific incompatible driver, then decide with the user |
| TPM / CPU / Secure Boot bypass registry or labconfig installs | Unsupported; future updates may refuse the device | Stay on a supported Windows 10/11 SKU or change hardware |
| Unofficial BIOS/firmware sites, “modded” OEM images | Brick and security risk | OEM support site or Windows Update firmware |
| Product-key finders, activation cracks, KMS “activators” | License and malware risk | Settings > System > Activation |
| One-click “Repair Windows”, “boost FPS 50%”, overlay closers that kill security processes | No evidence; often PUPs | Reliability Monitor + Task Manager |

## Conditional — only after a named diagnosis

- Fast Startup off: only if a driver, dual-boot, or update fails to apply across shutdown.
- Hardware-accelerated GPU scheduling: only on WDDM 2.7+ GPUs; test one session and revert on stutter or capture issues.
- `chkdsk /f` or `/r`: only after `/scan` (or SMART/volume health) shows a problem; `/r` is offline and long.
- DISM `/RestoreHealth` or `sfc /scannow`: only after CheckHealth/ScanHealth or a confirmed protected-file failure — and on this PC only after the user accepts Defender files may return.
- `DISM /StartComponentCleanup /ResetBase`: prevents uninstall of installed updates; use only when disk reclaim is required and rollback is no longer needed.
- Network reset / `netsh winsock reset` / flush DNS: only after adapter, DHCP, and DNS evidence, not as step 1.
- Clean boot / Safe Mode: diagnostic isolation, not a permanent configuration.
- Autoruns (Sysinternals): only if Settings Startup and Task Manager cannot show the entry. Microsoft-published; still propose each disable separately.

## Third-party tools that can be justified

State the gap, prefer the official or Microsoft-published build, and ask first.

| Tool | Gap vs built-in | Source |
|---|---|---|
| Sysinternals (Autoruns, Process Explorer, Process Monitor) | Persistence and handle views Settings does not show | Microsoft Learn / live.sysinternals.com |
| WinDbg / Windows Performance Analyzer | Dump and ETW analysis | Microsoft |
| OEM support app already on the PC (Lenovo diagnostics/firmware) | Firmware and thermal policy Windows Update may not ship | PC manufacturer |
| CrystalDiskInfo or vendor SSD tool | SMART attributes beyond `HealthStatus` | After `Get-PhysicalDisk` is insufficient |
| GPU vendor app (Intel Graphics Software, NVIDIA App, AMD Software) | Feature control the Settings GPU page lacks | Component vendor, not a “driver booster” |

Do not invent other exceptions.
