---
name: windows-11-security
description: Assess and change Windows 11 security posture using official controls only: TPM 2.0, UEFI Secure Boot, BitLocker, VBS/Memory Integrity, Smart App Control, SmartScreen, firewall, UAC, and antivirus registration. Use for security reviews, encryption, Core Isolation, or /windows-11-security. Never show recovery keys or disable protection as a diagnostic shortcut. On this PC, preserve the intentional Defender-removed configuration.
---

# Windows 11 security

Load `windows-pc-helper`. Default is report-only. Describe Windows Security and Privacy pages with `visual-guidance.md`. Any enable/disable of AV, BitLocker, VBS, Memory Integrity, firewall, BCD, or services follows `non-destructive-change.md` and is **never** labeled “safe.” Approval required.

## Baseline on this PC (inventory 2026-08-13)

- Secure Boot: Enabled
- TPM 2.0: present, ready, initialized; firmware not reported vulnerable
- Firewall: Domain/Private/Public enabled
- BitLocker on C:: off (admin scan 2026-08-12; 0% encrypted)
- UAC: enabled; secure-desktop prompt **off**
- Security Center antivirus: **none registered**
- Defender: **intentionally absent**; `MDCoreSvc` stopped/disabled; platform EXE absent

Do not “fix” Defender absence or turn BitLocker on as part of a generic hardening pass.

## Platform requirements (do not bypass)

Windows 11 requires a compatible 64-bit CPU, TPM **2.0**, and UEFI firmware that is **Secure Boot capable**. TPM 2.0 needs Native UEFI (no Legacy/CSM).

Refuse labconfig, `AllowUpgradesWithUnsupportedTPMOrCPU`, and Rufus/unsupported ISO tricks. They produce an unsupported device.

Check (omit serials, EK, and owner auth):

```powershell
Confirm-SecureBootUEFI
Get-Tpm | Select-Object TpmPresent, TpmReady, TpmEnabled, TpmActivated
Get-NetFirewallProfile | Select-Object Name, Enabled
Get-CimInstance -Namespace root/SecurityCenter2 -ClassName AntivirusProduct |
  Select-Object displayName, productState
```

If `Get-Tpm` is thin, `tpmtool getdeviceinformation` is the inventory fallback. Access denied means “unknown,” not “disabled.”

## Antivirus

1. Report Security Center registrations. Zero products is a posture choice here, not a broken WSC.
2. Do not install Microsoft Defender, a replacement AV, or re-enable `MDCoreSvc` unless the user explicitly asks. If they do, explain it conflicts with the documented intentional removal and may be undone by SFC/DISM RestoreHealth.
3. Do not disable a registered AV to “test performance.”

## BitLocker / device encryption

- Home: device encryption only on eligible hardware, not BitLocker To Go.
- Pro+: full BitLocker.
- This PC: C: fully decrypted. Enabling it is a **user decision**. Before any enable: where the 48-digit recovery password will be stored (Microsoft account, printed paper, or the user’s password manager — never this repo, never chat). Confirm they can unlock without the TPM alone.
- Never print recovery keys, protectors, or BEK paths in logs.

## VBS, Memory Integrity, Smart App Control

New Windows 11 installs turn VBS and HVCI (Memory Integrity) on when hardware allows. Cost is real (some latency, plus third-party hypervisor conflicts). Measure before disabling.

- Open Settings > Privacy & security > **Windows Security** > **Open Windows Security**. Left sidebar: Virus & threat protection, Account protection, Firewall & network protection, App & browser control, **Device security**, Device performance & health, Family options. On this PC, Virus & threat protection will not show an active Microsoft Defender product — that is expected.
- Device security → **Core isolation** (link) → **Memory integrity** toggle. A restart banner appears if you change it.
- Smart App Control: sidebar **App & browser control** → **Smart App Control settings**. Evaluation → On, or Off. **Off is not casually reversible** (typically reset/reimage). Do not toggle it as a tweak.
- Credential Guard / Memory Integrity / Hyper-V block many third-party hypervisors (KB3204980). If the user needs those, explain the trade; do not silently disable VBS.
- `hypervisorlaunchtype Off` does not always stop the hypervisor when HVCI or a WDAC/SAC policy is enforcing.

Do not disable Secure Boot, VBS, or Memory Integrity for FPS or as a first diagnostic step.

## Firewall and UAC

- Keep all three profiles on unless the user names one profile and a reason.
- UAC secure desktop off is a recorded gap on this PC. Turning it on is optional hardening (`PromptOnSecureDesktop`); propose, do not flip.
- Never collect account lists, SIDs, or credentials.

## If the user wants a change

State: exact setting, UI path from `visual-guidance.md`, what it protects or removes, restore-point evidence, how to undo, admin/restart, verification (`Get-Tpm`, `Confirm-SecureBootUEFI`, Security Center, `Get-BitLockerVolume` without key material). Then wait.
