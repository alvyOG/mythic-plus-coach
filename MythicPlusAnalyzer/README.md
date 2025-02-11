# Mythic Plus Analyzer

Mythic Plus Analyzer is a World of Warcraft addon designed to track and analyze various metrics during Mythic Plus dungeons. The addon provides detailed insights into your performance, including damage, healing, and progress tracking.

## Current Functionality

### As of [Date: 2025-02-10]
- **Core Functionality**:
  - Initializes and manages the addon.
  - Registers and handles events related to Mythic Plus dungeons.
  - Manages plugins and their interactions.

- **Plugins**:
  - **ProgressPlugin**: Tracks the progress time during Mythic Plus dungeons.
  - **DamagePlugin**: Tracks damage dealt during combat.
  - **HealingPlugin**: Tracks healing done during combat.

- **Core GUI**:
  - **CoreWindow**: Main window for displaying addon information and controls.
  - **CoreSettings**: Settings window for configuring the addon.

- **Custom Widgets**:
  - **AceGUI-IconButton-MPA**: Custom icon button widget.
  - **AceGUI-Window-MPA**: Custom window widget.

## Project Structure
```
MythicPlusAnalyzer/
├── Core.lua
├── CoreSegments.lua
├── CoreWindow.lua
├── CoreSettings.lua
├── Libs/
│   └── Ace3/
│   └── Ace3-MPA/
│       ├── AceGUI-IconButton-MPA.lua
│       └── AceGUI-Window-MPA.lua
├── Plugins/
│   ├── ProgressPlugin.lua
│   ├── DamagePlugin.lua
│   └── HealingPlugin.lua
└── MythicPlusAnalyzer.toc
```

## Installation

1. Download the latest version of the addon.
2. Extract the contents to your World of Warcraft `AddOns` directory.
3. Launch World of Warcraft and enable the addon in the AddOns menu.

## Usage

- Use the following slash commands to interact with the addon:
  - `/mpa-show`: Toggle the Core Window.
  - `/mpa-test`: Toggle the tracking state.
  - `/mpa-reset`: Reset tracking metrics.
  - `/mpa-settings`: Show the Settings Window.
  - `/mpa-settings-reset`: Reset settings.
  - `/mpa-progress-print`: Print progress time.
  - `/mpa-progress-reset`: Reset progress metrics.
  - `/mpa-damage-print`: Print damage metrics.
  - `/mpa-damage-reset`: Reset damage metrics.
  - `/mpa-healing-print`: Print healing metrics.
  - `/mpa-healing-reset`: Reset healing metrics.

## License

For more information, visit the project repository.

## Authors

- alvy023