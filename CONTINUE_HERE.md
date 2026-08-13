# Continuation checkpoint

Updated: 2026-08-13 (Asia/Taipei)  
Handoff: **Grok Build → Codex**. User is done for now; they will continue later.

## Start here (Codex)

1. Read `AGENTS.md`, `PROJECT_STATUS.md`, this file.
2. `git status --short --branch` — expect `main` **ahead of `origin/main` by 8** after this commit (7 unpushed skill/decision commits plus this handoff). Working tree should be clean.
3. Do **not** push unless the user explicitly asks.
4. For any PC work, load `$windows-pc-helper` then the matching specialist skill. Inventory is local and gitignored.

## Completed

- Windows 11 skill set under `.agents/skills/` (modular, progressive disclosure).
  - Orchestrator: `windows-pc-helper`
  - Specialists: `windows-11-operate`, `optimize`, `troubleshoot`, `maintain`, `security`, `hardware`
  - Shared refs: `windows-pc-helper/references/` (`sources.md`, `reject-unproven.md`, `visual-guidance.md`, `non-destructive-change.md`, `risk-and-privileges.md`, `editions-and-versions.md`, `windows-tool-map.md`)
  - This-PC hardware snapshot: `windows-11-hardware/references/this-pc.md`
- Unpushed commits on `main` (oldest first):
  - `f17b61a` Add Windows 11 operate/optimize/troubleshoot/maintain/security/hardware skills
  - `08d3ebf` Restore points + full Settings-path guidance
  - `3cad082` Principle 5 scope: storage, power, common troubleshooting
  - `3508626` Do not invent hardware requirements, hidden switches, unsupported configs
  - `b89c25a` Risk level and privileges on every action
  - `1156fb8` Move long tables into `references/`
  - `f3867d9` BitLocker declined; 25H2 not yet applied
  - *(this handoff commit)*
- User decisions:
  - **BitLocker: no** for now. Leave C: decrypted.
  - **Do not push** to `origin` yet.
  - Session paused; user will do remaining OS work later.

## Verified (live, 2026-08-13)

- Windows 11 Home **24H2**, build **26100.9168**. Not 25H2 (that would be **26200** / DisplayVersion 25H2).
- Last boot 2026-08-13 09:54. No pending-reboot markers.
- Quality updates present: KB5121003, KB5120710, KB5123304 (2026-08-12). **No** KB5054156 enablement package.
- Defender remains intentionally absent; do not “repair” it.
- Inventory snapshot in `inventory/` is from 2026-08-13 09:26 (still 24H2). Refresh after 25H2 actually applies.

## Constraints

- Preserve Defender-removed posture. No DISM `/RestoreHealth` or SFC unless the user accepts Defender files may return.
- Do not enable BitLocker unless the user reopens it and plans recovery-key storage.
- Do not invent hardware requirements, hidden switches, or unsupported configs (no labconfig / TPM bypass / 26H1 in-place).
- Surface `Risk` + `Privilege` + `Restart` on every action (`risk-and-privileges.md`).
- No snake-oil; built-in tools first; full Settings-path guidance; no generated fake Settings UI.
- Do not commit `inventory/` or `work/`. Do not push until asked.

## Next action

When the user returns and wants 25H2: Settings > Windows Update → **Download and install Windows 11, version 25H2** (enablement package, one restart). `Risk: Medium` · `Privilege: Standard` · `Restart: Yes`. Then refresh inventory and update this file. Until then: no PC changes required.

## Open decisions

- Apply the 25H2 enablement package (user intends to; **not on disk yet**).
- When (if ever) to push the local `main` commits to `origin`.
