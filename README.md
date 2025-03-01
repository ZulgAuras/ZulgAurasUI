# ZulgAurasUI

A lightweight, modular, and highly customizable World of Warcraft Classic UI addon optimized for performance and simplicity.

## Features

- **Unit Frames**: Customizable frames for player, target, focus, and party/raid
- **Action Bars**: Lightweight and customizable with cooldown timers and keybind support
- **Buff/Debuff Tracking**: Efficient aura management with filtering
- **Minimap**: Enhanced minimap with customization options
- **Chat Frame**: Improved chat functionality
- **Performance Optimized**: Minimal CPU and memory usage
- **Modular Design**: Enable/disable components as needed

## Installation

1. Download the latest release from the [releases page](https://github.com/ZulgAuras/ZulgAurasUI/releases)
2. Extract the ZIP file
3. Copy the `ZulgAurasUI` folder to your WoW Classic addons directory:
   - Windows: `C:\Program Files\World of Warcraft\_classic_\Interface\AddOns`
   - Mac: `/Applications/World of Warcraft/_classic_/Interface/AddOns`

## Usage

- Type `/zui` in-game to open the configuration panel
- Each module can be enabled/disabled independently
- Right-click frames to access quick settings

## Development

### Requirements

- World of Warcraft Classic client (v1.14.x)
- Basic understanding of Lua programming
- Git for version control

### Project Structure

```
ZulgAurasUI/
├── Libs/                  # Third-party libraries
├── Core/                  # Core addon functionality
├── Modules/              # Individual feature modules
│   ├── UnitFrames/
│   ├── ActionBars/
│   ├── Buffs/
│   ├── Minimap/
│   └── Chat/
├── Localization/         # Language files
└── Media/                # Textures and sounds
```

### Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

Distributed under the MIT License. See `LICENSE` for more information.

## Acknowledgments

- Inspired by ElvUI
- Thanks to the WoW addon development community

## Version History

- v1.0.0 - Initial release
  - Core functionality
  - Basic modules implementation
