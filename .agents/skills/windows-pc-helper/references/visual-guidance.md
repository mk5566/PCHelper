# Visual, whole-system guidance

Every user-facing procedure must be followable on a **full Windows 11 desktop** (24H2/25H2 Settings). Cover the whole relevant window, not an isolated key or a single button.

## Writing rules

1. Give the **exact path**: `Settings > System > Power & battery`, plus the `ms-settings:` URI when one exists.
2. Describe the **window as the user sees it**: app (Settings vs dialog vs MMC), left navigation, which item is selected, heading in the main pane, then controls **top to bottom**.
3. Name controls as labeled (toggle, dropdown, button, extra-link `>`). Mention the UAC shield if elevation is required.
4. State the **expected dialog** after each click (title + primary buttons).
5. If labels on this PC differ (zh-TW vs en-US), give both when the inventory locale is zh-TW: this PC’s Windows is **家用版** / Chinese (Taiwan). Prefer the English Learn name and the local glyph/position so either language works.
6. Cover related controls on that page (e.g. Power mode **and** Energy saver on the same Power & battery page). Do not jump to a registry value that the page already exposes.

## Screenshots

- **Allowed:** a capture of the **user’s live** Settings/dialog, or an official Microsoft Support screenshot that matches this version. Annotate with arrows/labels that match the written steps.
- **Forbidden:** generated or mocked Windows UI (Imagine, DALL·E, “fake Settings”). Invented chrome will not match 24H2/25H2 and will mislead.
- If no live capture is available, write the visual description below. Do not invent a picture.

## Settings chrome (24H2 / 25H2)

Settings is a two-pane window. **Left:** Home, System, Bluetooth & devices, Network & internet, Personalization, Apps, Accounts, Time & language, Gaming, Accessibility, **Privacy & security**, **Windows Update**. Home edition hides some System rows (Remote Desktop host). **Right:** page title, then stacked rows. A trailing `>` opens a subpage. Toggles sit on the right of each row.

Search box at the top of Settings filters pages; prefer a named path over search so the user lands on the full page.

| Task | Path | URI | What the main pane shows |
|---|---|---|---|
| About / edition / rename | Settings > System > About | `ms-settings:about` | Device specs, Windows specifications (edition, version, OS build), Related links including Advanced system settings |
| Display | Settings > System > Display | `ms-settings:display` | Brightness, night light, scale, resolution, refresh rate; **Graphics** at the bottom |
| Power & battery | Settings > System > Power & battery | `ms-settings:powersleep` | Battery graph (laptops), **Power mode** (Plugged in / On battery dropdowns: Best power efficiency, Balanced, Best performance), **Energy saver**, screen/sleep timeouts, Energy recommendations |
| Storage / Storage Sense | Settings > System > Storage | `ms-settings:storagesense` then Storage Sense `ms-settings:storagepolicies` | Drive C: bar, category list; Storage Sense toggle and cleanup rules |
| Recovery | Settings > System > Recovery | `ms-settings:recovery` | Recovery options: Fix problems using Windows Update, Advanced startup, Reset this PC; Point-in-time restore if offered |
| Optional features | Settings > System > Optional features | `ms-settings:optionalfeatures` | Installed features, View features, More Windows features (legacy OptionalFeatures.exe) |
| Startup apps | Settings > Apps > Startup | `ms-settings:startupapps` | Per-app toggle + measured impact (High/Medium/Low/Not measured) |
| Installed apps | Settings > Apps > Installed apps | `ms-settings:appsfeatures` | Search, sort, **…** → Advanced options / Uninstall |
| Default apps | Settings > Apps > Default apps | `ms-settings:defaultapps` | Search by app or file type |
| Windows Update | Settings > Windows Update | `ms-settings:windowsupdate` | Status, Check for updates, Pause, More options (Update history, Advanced, Optional updates) |
| Privacy | Settings > Privacy & security | `ms-settings:privacy` | Security (Windows Security), Windows permissions, App permissions list |
| Windows Security | Privacy & security > Windows Security > Open Windows Security | `windowsdefender:` | Sidebar: Virus & threat, Account protection, Firewall, App & browser, Device security, Device performance, Family |
| Core isolation | Windows Security > Device security > Core isolation details | — | Memory integrity toggle; restart banner |
| Gaming / Game Mode | Settings > Gaming > Game Mode | `ms-settings:gaming-gamemode` | Single Game Mode toggle; related Game Bar under Gaming > Xbox Game Bar |
| Activation | Settings > System > Activation | `ms-settings:activation` | Edition and activation state only — never product keys |

## Other whole windows

| Tool | How to open | Layout |
|---|---|---|
| Task Manager | Ctrl+Shift+Esc | Left icon rail (Processes, Performance, App history, Startup apps, Users, Details, Services). Processes: Name, Status, CPU, Memory, Disk, Network, GPU, **Efficiency mode**. |
| Reliability Monitor | `perfmon /rel` | Calendar of days; red circles = critical, yellow = warnings; bottom list of events that day. Click an event for source and check for a solution. |
| Event Viewer | `eventvwr.msc` | Left tree (Windows Logs > System / Application), center list, bottom preview. Filter Current Log rather than scrolling raw. |
| Device Manager | `devmgmt.msc` | Tree by class. Yellow triangle = problem. Right-click → Properties → **Driver** tab for version, Update, Roll Back, Uninstall. |
| System Protection | Start → **Create a restore point** | **System Properties** dialog, **System Protection** tab. See `non-destructive-change.md`. |

## Scope this project covers

In scope (principle 5, complete):

- Everyday user tasks (Settings, accounts, display, defaults)
- Performance tuning that actually works (measure first; see `windows-11-optimize`)
- Privacy and security **configuration the user asked for** (`windows-11-operate`, `windows-11-security`)
- Update and driver management (`windows-11-maintain`, `windows-11-hardware`)
- Storage optimization (Storage Sense, Temporary files, Delivery Optimization cache — not cleaners)
- Power optimization (Power mode, Energy saver, screen/sleep, Energy recommendations, `powercfg` reports)
- Common troubleshooting (Reliability Monitor, Event Viewer, isolation tests — `windows-11-troubleshoot`)

Do not invent hardware requirements, hidden switches, or unsupported configurations. Requirements come from [Windows 11 requirements](https://learn.microsoft.com/en-us/windows/whats-new/windows-11-requirements) and `sources.md`. If a Settings control is missing, treat it as unavailable — do not invent a registry, BCD, or labconfig substitute.

Out of scope unless the user names the risk and approves: firmware flash, partition/format, BitLocker enable without recovery-key plan, DISM RestoreHealth/SFC on this PC, mass service/task disable, unsupported TPM/CPU installs.
