# Continuation checkpoint

Updated: 2026-08-13 (Asia/Taipei)

## Completed

- Added and refined Windows 11 agent skills under `.agents/skills/`.
- Existing `$windows-pc-helper` is now the orchestrator: shared rules, inventory, change ladder, and dispatch table.
- New skills: `$windows-11-operate`, `$windows-11-optimize`, `$windows-11-troubleshoot`, `$windows-11-maintain`, `$windows-11-security`, `$windows-11-hardware`.
- Shared references (single home for each fact):
  - `windows-pc-helper/references/windows-tool-map.md` (Win11 routing)
  - `windows-pc-helper/references/reject-unproven.md`
  - `windows-pc-helper/references/sources.md` (official docs, retrieved 2026-08-13)
- `AGENTS.md` and `README.md` route to the new skills.

## Verified

- Each new `SKILL.md` has `name` + `description` frontmatter and a concise procedure body.
- No inventory, credentials, or machine-private files were added to tracked paths.
- Research used Microsoft Learn / Microsoft Support / WHCP pages dated through 2026-08-11 (release-health) and 2026-07-14 (requirements). Time-sensitive dates live only in `sources.md`.

## Constraints

- Never run DISM `/RestoreHealth` or SFC without explicit user acceptance that intentionally removed Defender payloads could be restored.
- Do not commit inventory data, credentials, keys, tokens, or user-private machine data.
- Preserve the user's deliberate Defender-removal configuration.
- Do not recommend registry cleaners, RAM boosters, debloat packs, driver-updater utilities, or TPM/CPU bypasses.

## Next action

Run `& '.\scripts\Test-RepositorySafety.ps1'`, review the skill diff, then commit the skill and guidance files only (not `inventory/` or `work/`). Push only if the user asks.

## Open decisions

- Whether to take the 25H2 enablement package from Windows Update (this PC is 24H2 / 26100).
- Whether to enable BitLocker after recovery-key storage is planned.
