<!--
SPDX-FileCopyrightText: 2025 hexaTune LLC
SPDX-License-Identifier: MIT
-->

<div align="center">

# 🎵 hexaGenApp

### Professional Frequency Generator for hexaTune Devices

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.9.2+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Linux%20%7C%20macOS%20%7C%20Windows-blue)](#)

<img src="hexagenapp/assets/icon/app_icon.png" alt="hexaGenApp Logo" width="120" height="120">

**Generate precise frequencies (0-20 MHz) • Control hexaTune devices • Cross-platform support**

[Features](#-features) •
[Getting Started](#-getting-started) •
[Documentation](#-documentation) •
[Contributing](#-contributing) •
[Support](#-support)

</div>

---

## 📖 Overview

**hexaGenApp** is a powerful Flutter-based mobile and desktop application designed to control hexaTune frequency generator hardware. Create complex frequency sequences, manage generation history, and monitor device status—all from an intuitive, multi-platform interface.

### ✨ Key Highlights

- 🎚️ **Frequency Control**: Generate frequencies from 0 Hz to 20 MHz with precision
- 📋 **Sequence Builder**: Create sequences up to 64 items with custom durations
- 📊 **Real-time Monitoring**: Track generation status with live updates
- 🔄 **History Management**: Save and replay past sequences (up to 50 entries)
- 🎨 **Theme Flexibility**: Light, dark, and high-contrast modes
- 🌍 **Multilingual**: English and Turkish support
- 🔌 **MIDI Communication**: USB MIDI connection to hexaTune devices
- ⚙️ **Background Service**: Continue generation even when app is in background

---

## 🚀 Features

### Core Functionality

#### 🎛️ Frequency Generation
- **Range**: 0 Hz - 20,000,000 Hz (20 MHz)
- **Sequence Length**: Up to 64 frequency items
- **Duration Control**: Set individual duration for each frequency
- **Repeat Mode**: Configure repeat count for sequences
- **Status Tracking**: Real-time status for each item (pending → processing → completed/error)

#### 📡 Device Communication
- **MIDI Protocol**: Industry-standard USB MIDI communication
- **AT Commands**: Custom command protocol for device control
  - `VERSION` - Query firmware version
  - `FREQ` - Set frequency and duration
  - `SETRGB` - Control LED colors
  - `RESET` - Reset device state
  - `FWUPDATE` - Firmware update mode
- **Auto-reconnect**: Automatic device detection and reconnection
- **Error Handling**: Comprehensive error codes (E001001-E001009)

#### 📜 Operation History
- **Persistent Storage**: Save up to 50 generation sequences
- **Regenerate**: Replay any past sequence with one tap
- **Detailed View**: Expandable cards showing full sequence data
- **Auto-cleanup**: FIFO deletion when limit reached

#### ⚙️ Settings & Diagnostics
- **Theme Selector**: Choose between light, dark, and high-contrast modes
- **Device Info**: View connection status and firmware version
- **Log Monitor**: Real-time log viewer with filtering by category and level
- **Auto-scroll**: Keep latest logs visible automatically

---

## 🎨 User Interface

### Navigation Structure

```
📱 hexaGenApp
├── 🎚️ Generation     - Build and execute frequency sequences
├── 📜 History         - View and replay past operations
├── 🛒 Products        - hexaTune product catalog (coming soon)
├── ❓ How to Use      - Usage instructions (coming soon)
└── ⚙️ Settings        - Theme, device info, logs
```

### Design System

- **Material Design 3**: Modern, adaptive UI components
- **Custom Color Scheme**:
  - Primary: Yellow/Gold (energy, precision)
  - Secondary: Cyan (connectivity, signals)
  - Tertiary: Purple (innovation, premium)
- **Typography**: 
  - Inter for body text and UI elements
  - Rajdhani for headings and titles
- **Accessibility**: High-contrast mode, WCAG 2.1 compliant

---

## 📦 Installation

### Prerequisites

- **Flutter SDK**: 3.x or later
- **Dart SDK**: ^3.9.2 or later
- **Platform Tools**:
  - Android: Android Studio + Android SDK
  - iOS: Xcode (macOS only)
  - Desktop: Platform-specific build tools

### Quick Start

```bash
# Clone the repository
git clone https://github.com/hTuneSys/hexaGenApp.git
cd hexaGenApp/hexagenapp

# Install dependencies
flutter pub get

# Verify setup
flutter doctor

# Run on connected device
flutter run

# Or specify platform
flutter run -d android
flutter run -d ios
flutter run -d linux
flutter run -d macos
flutter run -d windows
```

---

## 🏗️ Architecture

### Project Structure

```
hexagenapp/
├── lib/
│   ├── main.dart              # Entry point
│   ├── l10n/                  # Internationalization
│   └── src/
│       ├── app.dart           # Root app widget
│       ├── core/              # Core functionality
│       │   ├── at/            # AT command protocol
│       │   ├── device/        # Device management
│       │   ├── error/         # Error handling
│       │   ├── service/       # Core services
│       │   ├── sysex/         # MIDI SysEx protocol
│       │   └── theme/         # Theme system
│       └── pages/             # UI pages
├── assets/                    # Fonts, icons
├── android/                   # Android platform
├── ios/                       # iOS platform
├── linux/                     # Linux platform
├── macos/                     # macOS platform
├── windows/                   # Windows platform
└── test/                      # Tests
```

### Core Components

#### Services (Singleton Pattern)
- **DeviceService**: Device lifecycle, MIDI communication, command tracking
- **StorageService**: Persistent data (theme, history)
- **LogService**: Centralized logging with filtering

#### Communication Layer
- **HexaTuneDeviceManager**: MIDI device scanning and connection
- **AT Command Builder**: Protocol implementation
- **SysEx Handler**: Message encoding/decoding, USB MIDI packets

#### UI Layer
- **Generation Page**: Interactive sequence builder
- **History Page**: Operation history with replay
- **Settings Page**: Configuration and diagnostics

---

## 🛠️ Development

### Commands

```bash
# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
dart format .

# Build release
flutter build apk --release        # Android
flutter build ios --release        # iOS
flutter build linux --release      # Linux
flutter build macos --release      # macOS
flutter build windows --release    # Windows
```

### Branching Strategy

Use prefixed branch names:
- `feat/` - New features
- `fix/` - Bug fixes
- `refactor/` - Code refactoring
- `docs/` - Documentation
- `test/` - Tests
- `ci/` - CI/CD changes

### Commit Conventions

Follow conventional commits:
```
<type>(scope): <description>

Types: feat, fix, docs, style, refactor, perf, test, chore, ci, build, release, hotfix
```

Examples:
```bash
feat(generation): add drag-to-reorder for sequence items
fix(device): resolve MIDI connection timeout issue
docs(readme): update installation instructions
```

---

## 📚 Documentation

Comprehensive documentation is available in the `docs/` directory:

- **[Getting Started](docs/GETTING_STARTED.md)** - Quick setup guide
- **[Architecture](docs/ARCHITECTURE.md)** - System design and patterns
- **[Project Structure](docs/PROJECT_STRUCTURE.md)** - File organization
- **[Style Guide](docs/STYLE_GUIDE.md)** - Code conventions
- **[Branding](docs/BRANDING.md)** - Visual identity
- **[Contributing](docs/CONTRIBUTING.md)** - Contribution guidelines
- **[Development Guide](docs/DEVELOPMENT_GUIDE.md)** - Development workflow
- **[Branch Strategy](docs/BRANCH_STRATEGY.md)** - Git workflow
- **[Commit Strategy](docs/COMMIT_STRATEGY.md)** - Commit conventions

---

## 🤝 Contributing

We welcome contributions! Here's how to get started:

1. **Fork** the repository
2. **Create** a feature branch (`feat/amazing-feature`)
3. **Make** your changes following our [Style Guide](docs/STYLE_GUIDE.md)
4. **Test** your changes (`flutter test && flutter analyze`)
5. **Commit** using conventional commits
6. **Push** to your branch
7. **Open** a Pull Request

Read our [Contributing Guidelines](docs/CONTRIBUTING.md) for detailed information.

### Code of Conduct

This project follows our [Code of Conduct](docs/CODE_OF_CONDUCT.md). Please read it before contributing.

---

## 🔧 Hardware Requirements

To use frequency generation features:

- **hexaTune frequency generator device** (required for generation)
- **USB connection** (OTG adapter for mobile devices)
- **MIDI support** on your platform

> **Note**: The app runs without hardware, but generation features will be disabled.

---

## 🌍 Localization

Currently supported languages:

- 🇬🇧 **English** (default)
- 🇹🇷 **Turkish**

Want to add a language? See our [Localization Guide](docs/CONTRIBUTING.md#localization).

---

## 🧪 Testing

### Current Coverage
- Widget tests for UI components
- Unit tests for core logic

### Running Tests

```bash
# All tests
flutter test

# Specific test file
flutter test test/widget_test.dart

# With coverage
flutter test --coverage
```

---

## 📱 Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| Android  | ✅ Full | Android 5.0+ (API 21+) |
| iOS      | ✅ Full | iOS 12.0+ |
| Linux    | ✅ Full | Desktop support |
| macOS    | ✅ Full | macOS 10.14+ |
| Windows  | ✅ Full | Windows 10+ |
| Web      | 🚧 Beta | Limited MIDI support |

---

## 🐛 Known Issues

- **Web**: MIDI support limited by browser capabilities
- **iOS**: Background service requires audio permission
- **Android**: Some devices require manual USB permission grant

See [GitHub Issues](https://github.com/hTuneSys/hexaGenApp/issues) for complete list.

---

## 🗺️ Roadmap

### Version 1.1
- [ ] Complete "How to Use" page with tutorials
- [ ] Add "Products" catalog page
- [ ] Cloud sync for history
- [ ] Advanced sequence editing

### Version 1.2
- [ ] Firmware update UI
- [ ] Custom waveform generation
- [ ] Sequence templates
- [ ] Export/import sequences

### Version 2.0
- [ ] Multi-device support
- [ ] Remote control via Bluetooth
- [ ] Advanced analytics
- [ ] Custom scripting support

See [Project Board](https://github.com/hTuneSys/hexaGenApp/projects) for live progress.

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

### SPDX Compliance

All source files include SPDX license identifiers:
```
SPDX-FileCopyrightText: 2025 hexaTune LLC
SPDX-License-Identifier: MIT
```

---

## 🙏 Acknowledgments

- **Flutter Team** - Amazing cross-platform framework
- **flutter_midi_command** - MIDI communication library
- **Material Symbols** - Comprehensive icon set
- **hexaTune Community** - Feedback and testing

---

## 📞 Support & Contact

### Get Help

- 📧 **Email**: [info@hexatune.com](mailto:info@hexatune.com)
- 🐛 **Issues**: [GitHub Issues](https://github.com/hTuneSys/hexaGenApp/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/hTuneSys/hexaGenApp/discussions)
- 📖 **Documentation**: [docs/](docs/)

### Connect

- 🌐 **Website**: [hexatune.com](https://hexatune.com)
- 💻 **GitHub**: [github.com/hTuneSys](https://github.com/hTuneSys)
- 📱 **App Store**: Coming soon
- 🤖 **Play Store**: Coming soon

---

## 🏢 About hexaTune LLC

hexaTune LLC specializes in precision frequency generation hardware and software solutions for research, education, and professional applications.

**Mission**: Democratize access to high-quality frequency generation tools through open-source software and affordable hardware.

---

<div align="center">

### ⭐ Star us on GitHub!

If you find hexaGenApp useful, please consider starring the repository!

[![GitHub stars](https://img.shields.io/github/stars/hTuneSys/hexaGenApp?style=social)](https://github.com/hTuneSys/hexaGenApp/stargazers)

---

**Built with ❤️ by [hexaTune LLC](https://hexatune.com)**

[Website](https://hexatune.com) • [GitHub](https://github.com/hTuneSys) • [Email](mailto:info@hexatune.com)

</div>
