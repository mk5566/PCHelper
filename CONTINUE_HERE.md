# Continuation checkpoint

Updated: 2026-08-13 (Asia/Taipei)

## Completed

- Windows 11 skill set is complete and modular under `.agents/skills/`.
- Orchestrator: `$windows-pc-helper`. Specialists: operate, optimize, troubleshoot, maintain, security, hardware.
- Long facts live in `references/` (sources, reject list, visual guidance, restore points, risk/privileges, editions/versions, this-pc hardware).
- Shared principles: built-in first, no snake-oil, restore points before system-layer edits, visual whole-Settings paths, scoped work, no invented requirements/hidden switches, risk+privilege on every action, progressive disclosure.

## Verified

- Safety preflight to be run on this commit.
- No inventory or secrets tracked.

## Constraints

- Never run DISM `/RestoreHealth` or SFC without accepting Defender files may return.
- Do not invent hardware requirements, hidden switches, or unsupported configs.
- Surface risk and privileges on every action.
- Do not generate fake Settings screenshots.

## Next action

Push `main` only if the user asks (`origin` is several commits behind).

## Open decisions

- Whether to take the 25H2 enablement package (this PC is 24H2 / 26100 Home).
- Whether to enable BitLocker after recovery-key storage is planned.
