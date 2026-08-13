---
name: windows-11-optimize
description: Evidence-based Windows 11 performance, power, startup, and graphics tuning on x86/x64. Use when the user says the PC is slow, wants more battery or FPS, asks to disable startup apps, mentions Game Mode, HAGS, power mode, or runs /windows-11-optimize. Reject registry cleaners, RAM boosters, debloat packs, and unproven tweaks.
---

# Windows 11 optimize

Load `windows-pc-helper`. Treat `windows-pc-helper/references/reject-unproven.md` as mandatory (service killers and “gaming mode” scripts included). Write UI steps with `visual-guidance.md`. Registry/service/BCD edits require `non-destructive-change.md`.

Optimization without a before/after measurement is marketing. Measure, change one thing, re-measure.

## 1. Measure first

Read `inventory/PC_PROFILE.md` if it is < 30 days old; otherwise refresh inventory.

Live:

1. Task Manager (Ctrl+Shift+Esc): left rail **Processes**. Columns Name, Status, CPU, Memory, Disk, Network, GPU, **Efficiency mode**. Sort by CPU or GPU while the slowness is happening.
2. Resource Monitor or `Get-Process` / `Get-Counter` for the named hog.
3. Settings > System > **Power & battery** (`ms-settings:powersleep`): laptop battery graph at top; **Power mode** dropdowns for **Plugged in** and **On battery** (Best power efficiency / Balanced / Best performance); **Energy saver** row below; screen and sleep timeouts further down.
4. `powercfg /getactivescheme`
5. On battery issues: `powercfg /batteryreport /output` under `inventory/` (gitignored). On Modern Standby drain: `powercfg /sleepstudy`.

Record the top consumers and whether the device is on battery, Balanced/Best efficiency/Best performance, and thermally limited. Do not claim a “boost” without this baseline.

## 2. High-value, reversible levers (in order)

1. **Quit or uninstall the measured hog** (browser tabs, Electron apps, OEM overlay, RGB, “booster”). Use Settings > Apps, WinGet, or the vendor uninstaller. Not registry uninstall keys.
2. **Startup apps:** Settings > Apps > Startup (`ms-settings:startupapps`). Each row is an app name, publisher, impact (High/Medium/Low/Not measured), and a toggle on the right. Turn **off** one named item. Same list exists under Task Manager > Startup apps. On this PC: Figma Agent, Edge, Firefox, Telegram, Whatup — only what the user agrees to.
3. **Power mode:** Settings > System > Power & battery.
   - Battery life → Best power efficiency and/or Energy saver.
   - Interactive plugged-in work → Balanced (default on this PC).
   - Short burst of CPU/GPU work → Best performance, then put it back.
   Do **not** duplicate Ultimate Performance or switch the hidden High Performance plan on a Modern Standby laptop as the first step.
4. **Graphics:** Settings > System > Display → scroll to **Graphics** (`ms-settings:display-advancedgraphics`). Custom options for apps list + **Add desktop app**. **Change default graphics settings** is a separate subpage: **Hardware-accelerated GPU scheduling** appears only if the GPU/driver advertise WDDM 2.7+. Test one session; revert the same toggle on stutter. Do not set `HwSchMode` to force a missing control.
5. **Game Mode:** Settings > Gaming > Game Mode (`ms-settings:gaming-gamemode`). One toggle. This is the supported “gaming mode.” Refuse third-party gaming-mode scripts. Xbox Game Bar is the previous nav item — leave it off if it is the measured overlay.
6. **Storage pressure:** if free space is low or disk is the wait, follow `windows-11-maintain` (Storage Sense). Do not run a cleaner.
7. **Visual effects:** Settings > Accessibility > Visual effects, or System > About > Advanced system settings, only when the GPU/DWM is the measured bottleneck.

## 3. Do not touch without a specific diagnosis

- SysMain, Windows Search, Superfetch, prefetch.
- Pagefile (leave system-managed).
- Timer resolution, MMCSS, HPET, BCD “tweaks”, disable mitigations.
- Memory Integrity / VBS “for FPS” unless a named incompatible driver is proven and the user accepts the security trade.
- Services, scheduled tasks, or Defender/firewall.
- Core parking, “disable E-cores”, or third-party Thread Director replacements. On Intel Core Ultra (this PC: 155H) the Windows 11 scheduler is the supported path.

## 4. Efficiency Mode

Task Manager Efficiency mode is EcoQoS. Apply it to a *background* process that is stealing CPU from the foreground work. Do not put it on the app the user is trying to speed up. It is not a RAM booster.

## 5. Verify

Repeat the same Task Manager / battery / frame-time observation. Report what changed, what did not, and what remains. Revert any lever that did not help.
