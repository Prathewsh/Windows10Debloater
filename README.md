# Windows 10 Debloater Revamped

[![PowerShell](https://img.shields.io/badge/PowerShell-5.1-1f425f?style=flat-square&logo=powershell)](https://microsoft.com/PowerShell)
[![Windows targets](https://img.shields.io/badge/Windows-10%20(22H2)%20%2F%2011-0078d4?style=flat-square&logo=windows)](https://www.microsoft.com/windows)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](https://opensource.org/licenses/MIT)
[![GitHub issues](https://img.shields.io/github/issues/Prathewsh/Windows10Debloater?style=flat-square)](https://github.com/Prathewsh/Windows10Debloater/issues)
[![GitHub forks](https://img.shields.io/github/forks/Prathewsh/Windows10Debloater?style=flat-square)](https://github.com/Prathewsh/Windows10Debloater/network)


PowerShell scripts for removing bundled apps and changing Windows privacy and desktop settings, based on [Sycnex/Windows10Debloater](https://github.com/Sycnex/Windows10Debloater).

Use **Windows PowerShell 5.1 as Administrator**. The scripts target Windows 10 and recognize Windows 11, but compatibility with every build is not verified. Some registry tweaks, app names, and Start menu operations are specific to older Windows releases. PowerShell 7 and non-Windows hosts are not supported execution environments.

## Getting started

1. Download or clone this repository and extract the **complete folder**.
2. Review the scripts and back up important data. Broad removal can remove apps you use, including their provisioned packages for future users.
3. Open **Windows PowerShell as Administrator** and change to the extracted folder.
4. Allow scripts for this PowerShell session, then launch the GUI:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\Windows10DebloaterGUI.ps1
```

Keep `StabilityFunctions.ps1` beside the three main scripts. They stop if this dependency is missing. Do not pipe a single downloaded script into `Invoke-Expression`: the scripts require local companion files and a script path for elevation.

## Choose an entry point

| Script | Behavior |
| --- | --- |
| `Windows10DebloaterGUI.ps1` | Graphical controls for app removal, customization, privacy settings, and optional operations. |
| `Windows10Debloater.ps1` | Interactive message boxes for debloating and selected revert operations. |
| `Windows10SysPrepDebloater.ps1` | Switch-driven operations; safety checks can still prompt. It is not an unattended deployment tool. |
| `Individual Scripts/` | Standalone legacy snippets. Most do not run shared safety checks; inspect each before use. Some have no `.ps1` extension. |

Start with the GUI customization controls and inspect the app selection. Broad removal uses protection lists; it is more aggressive than removing listed bloatware. The actual package lists in the scripts are the source of truth and differ between entry points.

### SysPrep switches

```powershell
.\Windows10SysPrepDebloater.ps1 -Debloat
.\Windows10SysPrepDebloater.ps1 -Privacy
.\Windows10SysPrepDebloater.ps1 -Debloat -Privacy
```

- `-Debloat` removes apps outside its protection list, cleans associated registry entries, and attempts to register missing protected apps from packages still present on the machine.
- `-Privacy` applies privacy and telemetry settings.
- `-SysPrep` invokes the legacy preparation function, whose operations are currently commented out. It does not run Windows Sysprep or generalize an image.
- **With no switches, all three paths are selected.** Service checks run afterward regardless of switches.

## Safety and recovery

The main scripts check administrator privileges and the OS, offer to enable System Protection on the system drive, and attempt a restore point. They verify that a new point exists before reporting success. If creation fails or is throttled, continuing requires an explicit `Y` or `Yes` response. Windows normally limits new restore points to one per day; see Microsoft's [Checkpoint-Computer documentation](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/checkpoint-computer?view=powershell-5.1).

System Protection uses [Enable-ComputerRestore](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/enable-computerrestore?view=powershell-5.1). Restore points are not a backup of personal files or a guarantee that removed apps can be recovered.

OneDrive removal uses the installed uninstaller and checks its exit code. The scripts do not move or recursively delete sync folders, application data, or temporary OneDrive directories. Online-only files are not downloaded or backed up; ensure needed files are available before uninstalling. If no installer is found, use Windows Settings.

Revert controls restore selected settings and attempt app registration; they do not restore every original value or reinstall packages that are no longer present. Disabling Windows Update can prevent updates and may fail for protected services. Start menu unpinning and older Edge tweaks may have no effect on newer builds.

Caught safety-check failures are logged to `C:\Temp\Windows10Debloater\errors.log`; this is not a complete audit of every operation. Review console errors as well.

## Recent fixes

- Corrected invalid OEM wildcard syntax in regex protection lists.
- Fixed the System Protection command, forwarded restore-point descriptions, and checked restore-point creation results.
- Required the shared safety file instead of silently skipping checks.
- Initialized GUI message-box support before elevation and made cancellation exit.
- Replaced duplicated OneDrive cleanup with one shared uninstaller that preserves user folders and checks failures.
- Corrected the interactive and SysPrep repair checks to look for missing apps in the current user account before finding installed packages across users.
- Made general errors visible in the interactive and GUI scripts.

## **Bloatware Coverage**
The following lists preserve the original app coverage reference. Selection and protection rules differ between scripts; an app listed here is not necessarily removed by every mode. Review the package lists and GUI selection before running.

<details>
<summary><b>Click to view full list of removed apps</b></summary>

### **Modern Apps (2024-2026)**
- Clipchamp, Microsoft Teams, Microsoft To Do, Power Automate, Cortana (Standalone), Disney+, Spotify, Xbox Gaming App, Phone Link.

### **Original Bloatware List**
- [3DBuilder](https://www.microsoft.com/en-us/p/3d-builder/9wzdncrfj3t6), [ActiproSoftware](https://www.microsoft.com/en-us/p/actipro-universal-windows-controls/9wzdncrdlvzp), [Alarms](https://www.microsoft.com/en-us/p/windows-alarms-clock/9wzdncrfj3pr?activetab=pivot:overviewtab), [Appconnector](https://www.microsoft.com/en-us/p/connector/9wzdncrdjmlj?activetab=pivot:overviewtab), [Asphalt8](https://www.microsoft.com/en-us/p/asphalt-8-racing-game-drive-drift-at-real-speed/9wzdncrfj26j?activetab=pivot:overviewtab), [Autodesk SketchBook](https://www.microsoft.com/en-us/p/autodesk-sketchbook/9nblggh4vzw5), [MSN Money](https://www.microsoft.com/en-us/p/msn-money/9wzdncrfhv4v?activetab=pivot:overviewtab), [Food And Drink](https://www.microsoft.com/en-us/p/food-and-drink/9nblggh0jhqg), [Health And Fitness](https://www.microsoft.com/en-us/p/health-fitness-free/9wzdncrcwcdp), [Microsoft News](https://www.microsoft.com/en-us/p/microsoft-news/9wzdncrfhvfw#activetab=pivot:overviewtab), [MSN Sports](https://www.microsoft.com/en-us/p/msn-sports/9wzdncrfhvh4?activetab=pivot:overviewtab), [MSN Travel](https://www.microsoft.com/en-us/p/msn-travel/9wzdncrfj3ft?activetab=pivot:overviewtab), [MSN Weather](https://www.microsoft.com/en-us/p/msn-weather/9wzdncrfj3q2?activetab=pivot:overviewtab), BioEnrollment, [Windows Camera](https://www.microsoft.com/en-us/p/windows-camera/9wzdncrfjbbg#activetab=pivot:overviewtab), CandyCrush, CandyCrushSoda, Caesars Slots Free Casino, ContactSupport, CyberLink MediaSuite Essentials, DrawboardPDF, Duolingo, EclipseManager, Facebook, FarmVille 2 Country Escape, Flipboard, Fresh Paint, Get started, iHeartRadio, King apps, Maps, March of Empires, Messaging, Microsoft Office Hub, Microsoft Solitaire Collection, Microsoft Sticky Notes, Minecraft, Netflix, Network Speed Test, NYT Crossword, Office Sway, OneNote, OneConnect, Pandora, People, Phone, Phototastic Collage, PicsArt-PhotoStudio, PowerBI, Royal Revolt 2, Shazam, Skype for Desktop, SoundRecorder, TuneInRadio, Twitter, Windows communications apps, Windows Feedback, Windows Feedback Hub, Windows Reading List, XboxApp, Xbox Game CallableUI, Xbox Identity Provider, Zune Music, Zune Video, Mixed Reality Portal, Paint 3D, 3D Viewer.
</details>

---

## **Detailed Changelog (Revamped Fork)**

<details>
<summary><b>Click to view all technical improvements and bug fixes</b></summary>

These entries describe the fork’s earlier changes, with corrections where the current implementation differs. See **Recent fixes** above for this update.

### **Critical Bug Fixes**
- **Fixed crash-causing undefined functions** — `DisableDiagTrack` and `DisableWAPPush` were called but never defined, causing the interactive script to crash mid-execution.
- **Fixed broken OneDrive uninstall** — the `UninstallOneDrive` function had ~80 lines of duplicated/nested code that ran the uninstall twice.
- **Fixed broken regex whitelist** — backticks inside single-quoted strings silently prevented apps like `Microsoft.XboxGameCallableUI` and `Microsoft.HEIFImageExtension` from being whitelisted.
- **Fixed `Stop-Process` syntax** — `Stop-Process Explorer.exe` was treating the name as a process ID; corrected to `Stop-Process -Name Explorer -Force`.
- **Fixed `New-PSDrive` inside array** — in the GUI script, `New-PSDrive` was accidentally placed inside a `$Keys` array literal.
- **Fixed SysPrep switch parameters** — the script was ignoring `-Debloat`, `-SysPrep`, and `-Privacy` switches and always running everything.
- **Added missing `-Privacy` parameter** — documented in original README but never declared.
- **Fixed allowlist/blocklist conflicts** — Xbox apps were in both lists simultaneously.
- **Fixed `FixWhitelistedApps`** — `Select-Object` was used incorrectly and never actually checked if apps were installed.
- **Fixed SysPrep and PXE Boot failures** — Stopped the script from disabling the `DmClient` scheduled task and forcefully stopping `dmwappushservice`.
- **Fixed Minecraft/Xbox sign-in issues** — Stopped the script from disabling the `XblGameSaveTask` scheduled task.
- **Fixed missing Toast Notifications and Screen Snip** — Removed the `NoTileApplicationNotification` registry override.
- **Fixed OEM app removals (Acer, HP, Lenovo, etc.)** — Added OEM vendor wildcards to the Protected/NonRemovable lists so critical proprietary functionality is no longer broken.
- **Unpin Start feature** — The interactive script uses a Start layout XML method, while the GUI invokes shell unpin verbs. Behavior depends on Windows version and display language; a working CloudStore reset is not implemented by these entry points.
- **Fixed Customize GUI** — Resolved "not ticking" checkbox issue and added Select/Deselect All buttons.
</details>

<details>
<summary><b>Click to view new features and support</b></summary>

### **New Features Supported**
- **Windows 10 22H2 adjustments** — Includes updated search and telemetry settings. Full compatibility across Windows 10 and Windows 11 builds has not been verified.
- **Windows Update Management** — Includes commands to disable or re-enable Windows Update services (`wuauserv`, `WaaSMedicSvc`, `UsoSvc`) via Individual Scripts, interactive prompts, and GUI buttons. Protected services may reject changes; the commands do not guarantee that updates are completely disabled.
- **Bing Search (22H2 Fix)** — Uses `DisableSearchBoxSuggestions` (the `BingSearchEnabled` key is ignored on 22H2).
- **Telemetry tasks**: Disables `Microsoft Compatibility Appraiser`, `ProgramDataUpdater`, and `Proxy` (Application Experience tasks).
- **Services**: Includes telemetry service settings. Behavior differs by entry point; the SysPrep script checks and re-enables `dmwappushservice` for deployment compatibility.
- **Removed obsolete Wi-Fi Sense code** — Wi-Fi Sense was removed in Windows 10 version 1607 (2016).
</details>

---

## Validation

From Windows PowerShell, run:

```powershell
.\tests\Validate.ps1
```

This parses the main scripts and individual snippets, compiles literal protection regexes, and runs mocked restore-point and uninstaller failure checks. GitHub Actions runs it with Windows PowerShell. These checks do not execute debloating or certify Windows compatibility; test changes in a disposable Windows VM before using them on a primary machine.

## **Credits & Contributors**
Original project: [Sycnex/Windows10Debloater](https://github.com/Sycnex/Windows10Debloater).

Special thanks to the original contributors for the suggestions, code, and fixes:
**a60wattfish, abulgatz, xsisbest, Damian, Vikingat-RAGE, /u/GavinEke**, and everyone listed [here](https://github.com/Sycnex/Windows10Debloater/graphs/contributors).

---
 **Testers welcome!** If you encounter any issues, please [open an issue](https://github.com/Prathewsh/Windows10Debloater/issues).

Licensed under [MIT](LICENSE).
