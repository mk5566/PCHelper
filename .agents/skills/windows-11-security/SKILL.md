---
name: windows-11-security
description: Assess and change Windows 11 security posture using official controls only: TPM 2.0, UEFI Secure Boot, BitLocker, VBS/Memory Integrity, Smart App Control, SmartScreen, firewall, UAC, and antivirus registration. Use for security reviews, encryption, Core Isolation, or /windows-11-security. Never show recovery keys or disable protection as a diagnostic shortcut. On this PC, preserve the intentional Defender-removed configuration.
---

# Windows 11 security

Load `windows-pc-helper`. Default is report-only. Describe Windows Security and Privacy pages with `../windows-pc-helper/references/visual-guidance.md`. Any enable/disable of AV, BitLocker, VBS, Memory Integrity, firewall, BCD, or services follows `../windows-pc-helper/references/non-destructive-change.md` and is **never** labeled “safe.” Approval required.

## Baseline on this PC

Read `../../../inventory/PC_PROFILE.md` Security snapshot when the local inventory exists (refresh if older than 30 days). Last known: Secure Boot on, TPM 2.0 ready, firewall all profiles on, BitLocker off, UAC on without secure desktop, **no** Security Center AV, Defender **intentionally absent**. Do not “fix” Defender absence or enable BitLocker in a generic hardening pass.

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
- Credential Guard / Memory Integrity / Hyper-V can conflict with third-party virtualization products or make them use a Hyper-V-compatible mode (KB3204980). Confirm the current product/version behavior before changing VBS; do not silently disable security.
- `hypervisorlaunchtype Off` is the documented BCD control that prevents the Windows hypervisor from launching for that boot entry. It requires a restart. If Windows still reports a hypervisor afterward, verify the selected boot entry and collect feature, VBS, policy, and runtime evidence; do not claim an override without authoritative evidence.

Do not disable Secure Boot, VBS, or Memory Integrity for FPS or as a first diagnostic step.

## Firewall and UAC

- Keep all three profiles on unless the user names one profile and a reason.
- UAC secure desktop off is a recorded gap on this PC. Turning it on is optional hardening (`PromptOnSecureDesktop`); propose, do not flip.
- Never collect account lists, SIDs, or credentials.

## If the user wants a change

State: exact setting, UI path from `../windows-pc-helper/references/visual-guidance.md`, what it protects or removes, applicable recovery evidence, how to undo, admin/restart, verification (`Get-Tpm`, `Confirm-SecureBootUEFI`, Security Center, `Get-BitLockerVolume` without key material). Then wait.
