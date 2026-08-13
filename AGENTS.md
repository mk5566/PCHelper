# PC Helper project guidance

## Purpose

Help the user understand, troubleshoot, and maintain this Windows PC using evidence from the local machine. Prefer Windows built-in tools and existing installed software. Ask the user before downloading or installing anything.

## Required workflow

1. Read `inventory/PC_PROFILE.md` and `inventory/BASELINE_ASSESSMENT.md` when they exist.
2. Use the `$windows-pc-helper` skill as the orchestrator. Dispatch Windows 11 work to `$windows-11-operate`, `$windows-11-optimize`, `$windows-11-troubleshoot`, `$windows-11-maintain`, `$windows-11-security`, or `$windows-11-hardware`. Reject unproven tweaks listed in `.agents/skills/windows-pc-helper/references/reject-unproven.md`.
3. Refresh the inventory when it is missing, older than 30 days, or the user reports a material hardware/software change.
4. Separate observed facts, interpretations, recommendations, actions taken, and unresolved questions.
5. Verify outcomes after every system change.

## Safety and privacy

- Default to read-only inspection. Never change Windows settings, registry values, services, drivers, startup entries, applications, partitions, firmware, encryption, firewall rules, accounts, permissions, or files outside this project without explicit user approval for the specific change.
- Before a material change, explain impact, reversibility, administrator needs, restart requirements, and the verification plan. Never call a change “safe” if it can leave the system inconsistent or less secure.
- Before registry, services, drivers, scheduled tasks, boot configuration, or system files: create or confirm a System Restore point (see `.agents/skills/windows-pc-helper/references/non-destructive-change.md`) and a user-data backup when files or boot are in scope.
- Write user-facing steps for the full Windows 11 Settings/desktop surface (`.agents/skills/windows-pc-helper/references/visual-guidance.md`). Do not generate fake Settings screenshots.
- Prefer reversible Windows-native actions. Create or confirm a recovery path before high-impact work.
- Do not collect or store passwords, tokens, cookies, browser history, Wi-Fi profiles or keys, product keys, recovery keys, document contents, email, chat data, precise IP addresses, MAC addresses, hardware serial numbers, or user account lists.
- Do not upload the inventory or logs. Keep generated inventory under `inventory/`, which is intentionally ignored by Git.
- Do not use registry uninstall keys as an uninstall mechanism. Use Windows Settings, WinGet, or the vendor's supported uninstaller after approval.
- Do not use debloat scripts, registry cleaners, driver-updater utilities, or third-party tuning tools.

## Tool preference

Use this order unless evidence requires otherwise:

1. Windows Settings and built-in troubleshooters.
2. PowerShell/CIM, Event Viewer logs, Reliability Monitor data, Device Manager, Windows Security, Storage, DISM, SFC, CHKDSK, PowerCfg, WinGet, and WSL commands already present.
3. Official Microsoft or hardware-vendor documentation.
4. A new application only when built-in and already-installed tools cannot meet the need; explain why and ask before any download.

## Project files

- `.agents/skills/windows-pc-helper/SKILL.md`: orchestrator, inventory, change ladder.
- `.agents/skills/windows-11-*/SKILL.md`: Windows 11 operate, optimize, troubleshoot, maintain, security, hardware.
- `.agents/skills/windows-pc-helper/scripts/Collect-PCInventory.ps1`: privacy-filtered read-only collector.
- `.agents/skills/windows-pc-helper/scripts/Test-PCInventory.ps1`: output validation.
- `.agents/skills/windows-pc-helper/references/`: tool map, rejected-advice list, dated official sources, restore-point procedure, visual Settings map.
- `inventory/PC_PROFILE.md`: latest human-readable PC profile.
- `inventory/BASELINE_ASSESSMENT.md`: dated interpretation of the latest baseline, with evidence boundaries.
- `inventory/raw/`: latest machine-readable inventory and tables.

## PowerShell conventions

- Use PowerShell 7 when available; keep scripts compatible with Windows PowerShell 5.1 where practical.
- Use `-LiteralPath`, explicit error handling, and non-interactive commands.
- Treat access-denied results as partial evidence, not as proof a feature is absent.
- Do not suppress errors that affect a conclusion; record them under inventory collection warnings.

## Cross-tool collaboration and Git safety

This repository is shared between Codex, Google Antigravity, Grok Build, and
human contributors. Treat repository files—not any assistant chat—as the
portable source of truth.

- Before work, read `AGENTS.md`, `PROJECT_STATUS.md`, and `CONTINUE_HERE.md`,
  then inspect `git status --short --branch`. Preserve unrelated changes.
- Never commit credentials, SSH private keys, access tokens, cookies, browser
  profiles, API keys, recovery material, or `.env` values. Do not print them in
  logs or ask users to paste them into chat. Use ignored local files or the
  tool/provider's secret store.
- Before a commit or push, inspect staged filenames, run a secret-pattern
  filename/content check, run relevant validation, and use `git diff --check`.
  Never bypass this policy with `git add -f`.
- Update `CONTINUE_HERE.md` whenever a task changes the project state. Record
  completed work, verification, constraints, the next action, and any user
  decision still required.
- Use small, focused commits with descriptive messages. Do not force-push,
  rewrite history, or change remotes without explicit user approval.
