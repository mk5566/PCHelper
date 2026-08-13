---
name: windows-pc-helper
description: Inspect, understand, diagnose, and safely maintain this specific Windows PC. Use for hardware or software inventory, performance, storage, startup, drivers, devices, Windows Update, security, networking, battery, crashes, errors, app problems, cleanup, configuration, or upgrade-readiness requests. Prefer Windows built-in tools and existing installed apps; require user approval before downloads, installs, removals, or system changes.
---

# Windows PC Helper

Use the local inventory as the baseline, gather current evidence, and choose the least invasive effective action.

## Route the request

- **Inventory or orientation:** Run `scripts/Collect-PCInventory.ps1`, then read `inventory/PC_PROFILE.md`, `inventory/BASELINE_ASSESSMENT.md` when present, and the relevant raw table.
- **Diagnosis:** Read the profile, reproduce or observe the symptom when safe, collect focused Windows evidence, form ranked hypotheses, and test the cheapest discriminating hypothesis first.
- **Recommendation:** Compare compatibility, impact, cost, reversibility, and risk. Clearly label facts versus inference.
- **Maintenance or repair:** Propose the exact change first. Act only after approval, then verify the result and record what changed.

Read `references/windows-tool-map.md` when choosing diagnostic commands, evaluating administrator requirements, or considering a repair.

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
   - administrator or restart requirements.

## Change ladder

Escalate only as far as needed:

1. Explain or observe.
2. Change an application setting that is easy to undo.
3. Use a supported Windows setting or built-in troubleshooter.
4. Repair Windows components with the narrowest supported command.
5. Update or roll back a driver through Windows Update, Device Manager, or the hardware vendor.
6. Install, remove, reset, repartition, change firmware, or change security controls only with specific approval and a recovery plan.

Before steps 2–6, state the exact target, effect, reversibility, risk, admin requirement, restart expectation, and verification check.

## Downloads and external research

- Use Windows-native and already-installed tools first.
- Browse only when current Microsoft or vendor information is needed.
- Prefer official Microsoft, PC manufacturer, component manufacturer, or application publisher sources.
- If a new tool is genuinely necessary, explain the capability gap and ask before download or installation.
- Never recommend registry cleaners, debloat packs, unofficial driver sites, key tools, or opaque optimization scripts.

## Evidence boundaries

- Do not claim a root cause from correlation alone.
- Do not treat a clean summary as proof that no fault exists.
- Do not expose or store credentials, recovery material, user content, precise network identifiers, or device serials.
- Do not upload local files, inventories, dumps, or logs without explicit permission.
- Preserve unrelated files and settings.
