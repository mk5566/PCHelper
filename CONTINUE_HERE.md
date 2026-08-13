# Continuation checkpoint

Updated: 2026-08-13 (Asia/Taipei)

## Completed

- Windows 11 skills exist under `.agents/skills/` (commit `f17b61a` plus this follow-up).
- Shared rules now match the five operating principles: built-in first, correctness over marketing, non-destructive modification, visual whole-system guidance, scoped everyday/performance/privacy/update/driver work.
- New references (single home each):
  - `windows-pc-helper/references/non-destructive-change.md` — restore point UI/CLI, rollback, never call unsafe changes “safe”
  - `windows-pc-helper/references/visual-guidance.md` — Settings chrome, full-page descriptions, no generated fake UI
- Reject list now includes service killers and unproven “gaming mode” scripts.
- Specialist skills point at those references and include 24H2/25H2 control names.
- Principle 5 scope is complete: storage optimization, power optimization, and common troubleshooting are explicit in-scope items (maintain / optimize / troubleshoot).

## Verified

- Restore-point UI path matches Microsoft Support System Protection (retrieved 2026-08-13): Start → “Create a restore point” → System Protection → Create…
- No generated Settings mockups were added.
- Repository safety preflight to be run before commit. Inventory remains untracked.

## Constraints

- Never run DISM `/RestoreHealth` or SFC without explicit user acceptance that intentionally removed Defender payloads could be restored.
- Do not commit inventory data, credentials, keys, tokens, or user-private machine data.
- Preserve the user's deliberate Defender-removal configuration.
- Do not recommend registry cleaners, RAM boosters, service killers, gaming-mode scripts, driver-updater utilities, or TPM/CPU bypasses.
- Never present a registry/service/driver/BCD/system-file change as “safe.”

## Next action

Commit this follow-up on `main`. Push only if the user asks.

## Open decisions

- Whether to take the 25H2 enablement package from Windows Update (this PC is 24H2 / 26100).
- Whether to enable BitLocker after recovery-key storage is planned.
- None for the skill-scope brief. Principle 5 is complete: everyday tasks, working performance tuning, privacy/security configuration, updates and drivers, storage and power optimization, and common troubleshooting.
