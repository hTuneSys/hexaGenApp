<!--
SPDX-FileCopyrightText: 2025 hexaTune LLC
SPDX-License-Identifier: MIT
-->

# Getting Started with hexaGenApp

Welcome to hexaGenApp! This guide will help you quickly set up your development environment and start working with the project.

---

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (3.x or later)
- **Dart SDK** (^3.9.2 or later)
- **Git** for version control
- **IDE**: VS Code, Android Studio, or IntelliJ IDEA
- **Platform-specific tools**:
  - **Android**: Android Studio, Android SDK
  - **iOS**: Xcode (macOS only)
  - **Desktop**: Platform-specific build tools

---

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/hTuneSys/hexaGenApp.git
cd hexaGenApp/hexagenapp
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Verify Flutter Setup

```bash
flutter doctor
```

Fix any issues reported by Flutter Doctor before proceeding.

### 4. Run the Application

```bash
# Run on connected device or emulator
flutter run

# Or specify a platform
flutter run -d android
flutter run -d ios
flutter run -d linux
flutter run -d macos
flutter run -d windows
```

---

## 🏗️ Project Structure

```
hexagenapp/
├── lib/
│   ├── main.dart              # Application entry point
│   ├── l10n/                  # Internationalization (English, Turkish)
│   └── src/
│       ├── app.dart           # Root app widget
│       ├── core/              # Core services, device logic, theme
│       └── pages/             # UI pages (generation, history, settings)
├── assets/                    # Fonts, icons, images
├── test/                      # Widget and unit tests
└── pubspec.yaml              # Dependencies and configuration
```

---

## 🎯 Key Features

- **Frequency Generation**: Create and execute frequency sequences (0-20 MHz)
- **MIDI Communication**: Connect to hexaTune devices via USB MIDI
- **Operation History**: Track and replay past generation sequences
- **Multi-theme Support**: Light, dark, and high-contrast modes
- **Cross-platform**: Android, iOS, Linux, macOS, Windows, Web

---

## 🔧 Development

### Running Tests

```bash
flutter test
```

### Code Analysis

```bash
flutter analyze
```

### Format Code

```bash
dart format .
```

### Build Release

```bash
# Android APK
flutter build apk --release

# iOS IPA (macOS only)
flutter build ios --release

# Desktop
flutter build linux --release
flutter build macos --release
flutter build windows --release
```

---

## 📱 Hardware Requirements

To use frequency generation features, you need:

- **hexaTune hardware device** (frequency generator)
- **USB connection** (OTG adapter for mobile devices)
- **MIDI support** on your platform

The app will run without hardware but generation features will be disabled.

---

## 🌍 Localization

Currently supported languages:
- English (en) - Default
- Turkish (tr)

Add translations in `lib/l10n/app_*.arb` files.

---

## 📚 Documentation

- **[ARCHITECTURE.md](ARCHITECTURE.md)** - System architecture and design
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Contribution guidelines
- **[DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md)** - Detailed development instructions
- **[BRANDING.md](BRANDING.md)** - Visual identity and design system
- **[PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md)** - Detailed file organization

---

## 🤝 Contributing

We welcome contributions! Please read our [Contributing Guidelines](CONTRIBUTING.md) before submitting pull requests.

### Quick Contribution Steps

1. Fork the repository
2. Create a feature branch (`feat/your-feature`)
3. Make your changes
4. Run tests and linting
5. Commit using conventional commits
6. Open a pull request

---

## 🐛 Troubleshooting

### Common Issues

**Flutter not recognized**
```bash
# Add Flutter to PATH
export PATH="$PATH:`pwd`/flutter/bin"
```

**Dependencies not installing**
```bash
flutter pub cache repair
flutter clean
flutter pub get
```

**Build failures**
```bash
# Clean build artifacts
flutter clean
flutter pub get
flutter run
```

**MIDI device not detected**
- Ensure USB debugging is enabled (Android)
- Check USB connection
- Verify MIDI permissions
- Restart the app

---

## 📞 Support

Need help? Reach out:

- **Email**: [info@hexatune.com](mailto:info@hexatune.com)
- **Issues**: [GitHub Issues](https://github.com/hTuneSys/hexaGenApp/issues)
- **Discussions**: [GitHub Discussions](https://github.com/hTuneSys/hexaGenApp/discussions)

---

## 📄 License

This project is licensed under the MIT License. See [LICENSE](../LICENSE) for details.

---

You're now ready to explore and build with hexaGenApp. Happy hacking! 🎉

---

Built by [hexaTune LLC](https://hexatune.com) · GitHub: [hTuneSys/hexaGenApp](https://github.com/hTuneSys/hexaGenApp)
