---
name: windows-11-troubleshoot
description: Common Windows 11 troubleshooting with Reliability Monitor, Event Viewer, Task Manager, and other built-in evidence before any repair. Use for crashes, hangs, boot failures, random slowness, app errors, BSOD, “something is wrong,” or /windows-11-troubleshoot. Do not apply fixes during diagnosis unless the user also asked to repair.
---

# Windows 11 troubleshoot

Load `windows-pc-helper`. Diagnosis is read-only unless the user also asked for a fix. Describe each tool with `../windows-pc-helper/references/visual-guidance.md`. Do not disable security, reset the network stack, or run DISM/SFC/CHKDSK as step 1. Persistent isolation changes need approval, a captured baseline, and an applicable rollback (`../windows-pc-helper/references/non-destructive-change.md`).

## 1. Scope the symptom

Restate, in the user’s words: what fails, when it started, how often, what changed just before (update, driver, app, cable, heat), and the impact. Classify **current / intermittent / historical**.

## 2. Cheap evidence first

1. Read `../../../inventory/PC_PROFILE.md` and the Health / CollectionWarnings sections of the local `inventory/raw/inventory.json` when they exist. A clean clone will not contain inventory because it is intentionally ignored.
2. Reliability Monitor: Win+R → `perfmon /rel` → **Reliability Monitor** window. Top: stability index chart (days). Red circles = critical, yellow = warnings, blue = information. Click the day the user noticed the problem; the **Reliability details** list at the bottom shows source and event. Open the first critical in that cluster, not only the last.
3. Event Viewer: Start → **Event Viewer** or `eventvwr.msc`. Left tree: **Windows Logs > System**. Action pane → **Filter Current Log** → Event level: Critical and Error, Logged: Last 7 days. Or re-query if inventory is stale:

   ```powershell
   Get-WinEvent -FilterHashtable @{ LogName = 'System'; Level = 1,2; StartTime = (Get-Date).AddDays(-7) } |
     Group-Object ProviderName, Id | Sort-Object Count -Descending | Select-Object -First 20
   ```

4. Application log only if the failing app is named.
5. Task Manager / Resource Monitor **while the symptom is happening** (CPU, disk queue, GPU, commit, the specific process).
6. Device Manager / `Get-PnpDevice -PresentOnly` for problem codes.
7. Windows Update history + `Get-HotFix` if the failure began after Patch Tuesday or a feature update.

Do not collect minidumps, WER reports, or traces until the user agrees. They can contain paths and user data. Keep any copy under `inventory/` (gitignored).

## 3. Rank hypotheses

Score by (evidence × user impact) / cost-to-test. Test the cheapest discriminator first.

Typical Windows 11 buckets (use only if evidence fits):

| Bucket | Discriminator |
|---|---|
| App or overlay | Fails in one app; Reliability shows that app; clean boot removes it |
| Driver / firmware | Device problem code; faults start after a driver date; bugcheck `DRIVER_IRQL` / `VIDEO_TDR` |
| Servicing | Failures start after a KB; CBS errors; pending reboot |
| Storage | `HealthStatus` not Healthy; `chkdsk /scan` reports problems; disk 100% in Resource Monitor at idle |
| Power / thermal / Modern Standby | Only on battery or lid close; SleepStudy idle drain; unexpected wake |
| Memory / commit | Hard faults + commit near limit; not “low free RAM” alone |
| Network | One adapter or DNS path; `Test-NetConnection` fails; not generic “reset TCP” |
| Security / VBS conflict | Starts after Memory Integrity on, or third-party hypervisor vs Hyper-V |

On this PC, repeated NDIS 10317 on the **Wi-Fi Direct virtual** adapter is not proof the Intel AX211 user Wi-Fi is broken. Investigate only if the user sees disconnects, cast/hotspot failure, or sleep/resume network loss.

## 4. Isolation tests (still not repairs)

- Reproduce with overlays off (vendor GPU overlay, Game Bar, OEM utilities).
- Clean boot: System Configuration selective startup, or disable non-Microsoft startup apps only. Re-enable in batches.
- Safe Mode: firmware/driver vs user-mode.
- Another user account: per-user vs machine.
- Wired vs Wi-Fi, or another display: hardware path.

Stop when one test distinguishes the top two hypotheses.

## 5. Report, then maybe repair

Always report:

- observed facts
- likely interpretation and confidence
- ruled-out items
- next action
- risk, privilege, and restart (`../windows-pc-helper/references/risk-and-privileges.md`)

If the user wants a fix, hand off:

- servicing / DISM / SFC / CHKDSK / Update → `windows-11-maintain`
- driver / firmware / device → `windows-11-hardware`
- TPM / VBS / BitLocker / AV → `windows-11-security`
- power / startup / “make it faster” after the cause is load → `windows-11-optimize`

Do not run repairs “while we’re in Event Viewer.”
