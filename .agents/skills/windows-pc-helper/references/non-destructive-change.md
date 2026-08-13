# Non-destructive system modification

Applies before any change that touches the **registry, services, drivers, scheduled tasks, boot configuration (BCD), or system files**. Settings toggles that Windows exposes in the Settings app still need approval and a stated rollback, but they do not automatically require a restore point. Choose a recovery method that can actually reverse or contain the named change.

Never call a change **“safe”** if it can leave the system inconsistent, less secure, or harder to boot. Label every step with risk and privileges (`risk-and-privileges.md`).

## Before the change (required)

1. **State the exact scope.** Name the object (service, driver, value, task, BCD entry, file), the machine vs user hive, whether other apps share it, and whether security or hardware can break.
2. **Prefer the Settings or MMC surface** that changes only that object. Do not ship a `.reg` or service-disabling script that also touches unrelated keys.
3. **Create or confirm an applicable recovery path:**
   - System Restore point for Windows system files, registry, drivers, services, scheduled tasks, and installed-program state when System Protection is available and the restore point would materially help.
   - Device Manager **Roll Back Driver** or the previous official package for a single-driver change.
   - Export the exact registry value, service/task configuration, or BCD entry before changing it so the named object can be restored.
   - Confirm a user-data backup if the change can affect files or boot (disk repair, feature update, firmware, reset).
   - Firmware requires the OEM-supported BIOS/UEFI recovery or rollback procedure. System Restore does not capture or revert firmware.
4. **Write the rollback** in the same message: UI path or command, and what “success” looks like after rollback.
5. Wait for explicit approval.

System Restore reverts monitored **Windows files and registry state** and can affect installed programs. It does **not** restore firmware and is not a substitute for a user-data backup. Sources: [Restoring the system](https://learn.microsoft.com/en-us/windows/win32/sr/restoring-the-system), [System Restore](https://support.microsoft.com/windows/system-restore), [System Protection](https://support.microsoft.com/windows/system-protection) (retrieved 2026-08-13).

## Create a restore point (Windows 11)

System Protection is often **Off** on C: until someone enables it.

**UI (whole window):**

1. Open **Start**, type **Create a restore point**, press Enter. The search flyout lists a Control Panel result with that exact name.
2. The **System Properties** dialog opens on the **System Protection** tab (not Computer Name or Advanced). The window title is **System Properties**. Across the top: Computer Name, Hardware, Advanced, System Protection, Remote.
3. Under **Protection Settings** a list of drives shows **Protection** On or Off. Select **Local Disk (C:) (System)** and read the Protection column.
4. If Off and the user approves enabling it: **Configure…** → **System Protection for Local Disk (C:)** dialog → select **Turn on system protection** → choose a modest maximum usage appropriate to available disk space → **OK**. Record the chosen value. This reserves capacity for shadow copies; do not invent a universal percentage.
5. Back on System Protection: **Create…** → type a description that names the planned change → **Create** → wait for **The restore point was created successfully** → **Close**.
6. Confirm the new point exists: **System Restore…** → **Next** → the list should show today’s point. **Cancel** (do not restore now).

**CLI check / create (admin), after the user approved enabling protection:**

```powershell
Get-ComputerRestorePoint | Sort-Object CreationTime -Descending | Select-Object -First 5 SequenceNumber, CreationTime, Description, RestorePointType
Enable-ComputerRestore -Drive 'C:\'
Checkpoint-Computer -Description 'Before <named change>' -RestorePointType MODIFY_SETTINGS
```

`Checkpoint-Computer` may refuse another point within its creation-frequency window. If it does, record the failure and confirm whether a sufficiently recent restore point or a more specific rollback method already covers the change. Do not use an undocumented bypass. For High-risk work, stop if no adequate recovery path exists.

## Roll back

- **While Windows boots:** Start → type **Create a restore point** → **System Restore…** → pick the named point → finish the wizard (restart).
- **If Windows does not boot:** firmware/Start → **Settings > System > Recovery > Advanced startup > Restart now** → Troubleshoot → Advanced options → **System Restore**.
- Do not offer **Reset this PC** as the rollback for a registry/service/driver change. Reset is a reinstall path.

Driver-only rollback: Device Manager → device → Properties → **Driver** tab → **Roll Back Driver** (use this when only one driver changed).

Firmware rollback: follow only the PC manufacturer's documented recovery or rollback process for the exact model and installed firmware. Do not use System Restore as firmware recovery.

## After the change

Verify the stated success check. If the system is worse, roll back immediately using the written path. Record what was done; do not leave a half-applied script.
