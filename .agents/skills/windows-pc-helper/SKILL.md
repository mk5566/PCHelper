---
name: windows-pc-helper
description: Inspect, diagnose, and safely maintain this specific Windows PC using local inventory and Windows-native tools. Use for inventory, orientation, or any Windows 11 operate/optimize/troubleshoot/maintain request on this machine. Also use for /windows-pc-helper. Require approval before downloads, installs, removals, or system changes. Dispatch Windows 11 procedures to the sibling skills listed below.
---

# Windows PC Helper

Use the local inventory as the baseline, gather current evidence, and choose the least invasive effective action. This skill is the orchestrator for **this PC**. Load a sibling skill for the procedure; do not restate those procedures here.

## Shared rules (all Windows 11 work)

1. **Built-in first.** Settings, Task Manager, Resource Monitor, Reliability Monitor, Event Viewer, PowerShell/CIM, DISM, SFC, CHKDSK, Storage Sense, Windows Update, `powercfg`, Device Manager, Windows Security. A third-party tool only when it clearly adds a capability or accuracy the built-in tools lack; justify it, prefer Microsoft-endorsed or widely audited open source, and state the trust boundary. Ask before any download.
2. **Correctness over marketing.** Recommend only changes with documented net benefit. Reject the categories in `references/reject-unproven.md` (including service killers and unproven “gaming mode” scripts). **Do not invent hardware requirements, hidden switches, or unsupported configurations.** If a control is not on the Settings/MMC surface or in `references/sources.md`, say it is unknown or re-fetch Learn — do not invent a registry/BCD/labconfig workaround.
3. **Non-destructive modification.** Before registry, services, drivers, scheduled tasks, BCD, or system files: follow `references/non-destructive-change.md` — restore point or backup, exact impact, prefer a change that cannot break unrelated apps/security/hardware, written rollback. Never call a change “safe” if it can leave the system inconsistent or less secure.
4. **Visual, whole-system guidance.** User-facing steps follow `references/visual-guidance.md`: full Settings path, describe the live window (left nav, heading, controls top to bottom, dialogs). Capture the user’s real UI when possible. Never generate fake Settings screenshots.
5. **Scope.** Everyday tasks; measured performance; privacy/security configuration the user asked for; updates and drivers; **storage and power optimization**; **common troubleshooting**. Full list: `visual-guidance.md` “Scope this project covers.”
6. **Evidence, then action.** Separate observed facts, interpretation, recommendations, actions taken, and open questions. Verify after every change. Default is read-only until the user approves a named change.
7. **Risk and privileges.** For every action (including read-only), surface risk level and required privileges using `references/risk-and-privileges.md`. High or Destructive work stops for approval.
8. **Preserve intentional posture on this PC.** Microsoft Defender was deliberately removed. Do not run DISM `/RestoreHealth` or SFC without explicit acceptance that protected Defender files may return. Do not enable BitLocker until recovery-key storage is planned.

Read `references/windows-tool-map.md` before choosing a diagnostic or repair command. Read `references/sources.md` before stating version, servicing, or platform-requirement facts.

## Route the request

| User intent | Skill |
|---|---|
| Inventory, “what is this PC”, refresh baseline | This skill (inventory workflow) |
| Editions, Settings, feature updates, daily use, 24H2/25H2/26H1 | `windows-11-operate` |
| Speed, **power optimization**, startup, “optimize”, Game Mode, HAGS | `windows-11-optimize` |
| **Common troubleshooting**: crashes, errors, slowness diagnosis, boot problems | `windows-11-troubleshoot` |
| Windows Update, **storage optimization**, DISM/SFC/CHKDSK, backups | `windows-11-maintain` |
| TPM, Secure Boot, BitLocker, VBS, Memory Integrity, AV, firewall | `windows-11-security` |
| Drivers, firmware, devices, CPU/GPU/storage compatibility | `windows-11-hardware` |

- **Inventory or orientation:** Run `scripts/Collect-PCInventory.ps1`, then read `inventory/PC_PROFILE.md`, `inventory/BASELINE_ASSESSMENT.md` when present, and the relevant raw table.
- **Diagnosis:** Read the profile, reproduce or observe the symptom when safe, collect focused Windows evidence, form ranked hypotheses, and test the cheapest discriminating hypothesis first. Then follow `windows-11-troubleshoot`.
- **Recommendation:** Compare compatibility, impact, cost, reversibility, and risk. Clearly label facts versus inference.
- **Maintenance or repair:** Propose the exact change first. Act only after approval, then verify the result and record what changed.

## Inventory workflow

1. From the project root, run:

   ```powershell
   & '.\.agents\skills\windows-pc-helper\scripts\Collect-PCInventory.ps1'
   & '.\.agents\skills\windows-pc-helper\scripts\Test-PCInventory.ps1'
   ```

2. Treat collection warnings as missing evidence. Do not infer that an inaccessible feature is disabled or absent.
3. Read `inventory/PC_PROFILE.md` first, then the dated `inventory/BASELINE_ASSESSMENT.md` when present. Load only the relevant JSON or CSV sections for the user's question.
4. Refresh when the inventory is missing, older than 30 days, or hardware/software materially changed.
5. Never add secrets or omitted identifiers to the inventory merely for completeness.

## Diagnostic workflow

1. Restate the symptom, scope, timing, frequency, and impact using the user's words.
2. Establish whether the issue is current, intermittent, or historical.
3. Gather focused evidence with read-only tools. Prefer current state plus recent event counts before broad logs.
4. Rank hypotheses by evidence, likelihood, impact, and cost to test.
5. Run safe tests that distinguish hypotheses. Do not run repairs during diagnosis unless the user also asked for a fix.
6. Report:
   - observed facts;
   - likely interpretation and confidence;
   - ruled-out or unsupported possibilities;
   - recommended next action;
   - risk level, required privileges, and restart (see `references/risk-and-privileges.md`).

## Change ladder

Escalate only as far as needed:

1. Explain or observe.
2. Change an application setting that is easy to undo.
3. Use a supported Windows setting or built-in troubleshooter.
4. Repair Windows components with the narrowest supported command.
5. Update or roll back a driver through Windows Update, Device Manager, or the hardware vendor.
6. Install, remove, reset, repartition, change firmware, or change security controls only with specific approval and a recovery plan.

Before steps 2–6, state the exact target, effect, reversibility, **risk level**, **required privileges**, restart expectation, and verification check (`references/risk-and-privileges.md`). Before steps 4–6, or any registry/service/driver/task/BCD/system-file edit, complete `references/non-destructive-change.md`. Write the steps with `references/visual-guidance.md`.

## Downloads and external research

- Use Windows-native and already-installed tools first.
- Browse only when current Microsoft or vendor information is needed.
- Prefer official Microsoft, PC manufacturer, component manufacturer, or application publisher sources.
- If a new tool is genuinely necessary, explain the capability gap and ask before download or installation.
- Never recommend the categories in `references/reject-unproven.md` (registry cleaners, RAM boosters, debloat packs, unofficial driver sites, key tools, opaque optimizers).

## Evidence boundaries

- Do not invent hardware requirements, hidden switches, or unsupported configurations. Quote Learn/Support or the live UI. If the HAGS toggle, an edition feature, or a CPU/TPM requirement is absent, it is unsupported on this device — do not add `HwSchMode`, labconfig, or “secret” BCD/power-plan keys.
- Do not claim a root cause from correlation alone.
- Do not treat a clean summary as proof that no fault exists.
- Do not expose or store credentials, recovery material, user content, precise network identifiers, or device serials.
- Do not upload local files, inventories, dumps, or logs without explicit permission.
- Preserve unrelated files and settings.
