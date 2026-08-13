---
name: windows-11-operate
description: Operate Windows 11 correctly across Home, Pro, Pro Education, Pro for Workstations, Enterprise, Education, SE, and LTSC. Covers Settings vs Control Panel, everyday tasks, privacy toggles, feature updates (24H2, 25H2 enablement package, 26H1 new-silicon only), accounts, and display. Use when the user asks how to use Windows 11, which edition they have, whether to take 25H2/26H1, privacy settings, or runs /windows-11-operate.
---

# Windows 11 operate

Load `windows-pc-helper` first. For build/edition/feature-update facts, open `windows-pc-helper/references/editions-and-versions.md` and `sources.md` — do not restate those tables. Click-paths: `visual-guidance.md`. Risk line: `risk-and-privileges.md`.

## Identify, then advise

Run the identify commands in `editions-and-versions.md`. This PC last inventoried as **24H2 / 26100 / Home**. Confirm before recommending 25H2.

## Feature updates

Follow the rules in `editions-and-versions.md`. UI: Settings > **Windows Update** (`ms-settings:windowsupdate`) — status sentence, **Check for updates**, optional **Download and install Windows 11, version 25H2**, **Pause for 1 week**. Update history is a subpage.

`Risk: Low` (install offered update) or `Medium` (feature update) · `Privilege: Standard` (UAC if the package requires it) · `Restart: Yes` for 25H2.

## Everyday Settings

Open **Start > Settings**. Left nav stays visible. Prefer a named path. Whole-pane layouts live in `visual-guidance.md` (Display, About, Accounts, Default apps, Optional features, Privacy & security).

- Change one named control. Undo is the same toggle.
- Privacy: Settings > **Privacy & security**. Change one app permission the user named. No privacy-pack `.reg`. Optional diagnostic data can be reduced; required diagnostics cannot be turned off on Home.
- Optional features: do not remove Print to PDF, WCF, .NET 4 Advanced Services, or Windows Search here without naming the lost function. `Risk: Medium` · `Privilege: Admin`.
- WSL is not installed. `wsl --install` only after approval. `Risk: Medium` · `Privilege: Admin` · `Restart: likely`.

## Configuration changes

Change ladder in `windows-pc-helper`. Prefer a Settings toggle. Registry/service/optional-feature edits require `non-destructive-change.md`.
