# Windows PC Helper

This Codex project keeps a privacy-filtered understanding of this Windows PC and provides a safe workflow for troubleshooting and maintenance.

## What is included

- A local orchestrator skill (`windows-pc-helper`) plus Windows 11 skills for operate, optimize, troubleshoot, maintain, security, and x86/x64 hardware.
- A read-only inventory collector built from Windows PowerShell, CIM, registry inventory, and installed Windows modules.
- A human-readable PC profile plus JSON/CSV evidence for deeper analysis.
- Project safeguards that keep normal writes inside this folder and disable network access by default.

The collector intentionally excludes secrets, user content, account lists, network addresses, Wi-Fi details, serial numbers, browser data, product keys, and recovery keys. The `inventory/` folder is ignored by Git.

## Working across assistants

This repository is designed to move cleanly between Codex, Google Antigravity,
Grok Build, and human contributors. Start every task with
[`CONTINUE_HERE.md`](CONTINUE_HERE.md), then follow
[`COLLABORATION.md`](COLLABORATION.md). The repository never contains real
credentials or machine-private inventory data.

## Useful requests

- “Refresh my PC inventory and explain what changed.”
- “Why is this PC slow? Diagnose it without changing anything.”
- “Check storage health and tell me the safest cleanup options.”
- “Review startup apps and recommend what I can disable.”
- “Check Windows security, update, firmware, and driver posture.”
- “Help me fix this error; use Windows tools first.”

## Manual commands

Run an inventory from PowerShell:

```powershell
& '.\.agents\skills\windows-pc-helper\scripts\Collect-PCInventory.ps1'
```

Validate the generated files:

```powershell
& '.\.agents\skills\windows-pc-helper\scripts\Test-PCInventory.ps1'
```

Run the shared Git safety preflight before committing:

```powershell
& '.\scripts\Test-RepositorySafety.ps1'
```

Validate skill frontmatter and relative Markdown references directly:

```powershell
& '.\scripts\Test-SkillReferences.ps1'
```

Run the same scan as administrator from a normal PowerShell window:

```powershell
Start-Process powershell.exe -Verb RunAs -Wait -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-File',"$PWD\.agents\skills\windows-pc-helper\scripts\Run-AdminInventory.ps1"
```

Some security and device details are only visible in an administrator PowerShell window. A normal-user scan is still useful and records any inaccessible sections as warnings.
