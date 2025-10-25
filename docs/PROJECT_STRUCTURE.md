<!--
SPDX-FileCopyrightText: 2025 hexaTune LLC
SPDX-License-Identifier: MIT
-->

# 📁 Project Structure

This document provides a comprehensive overview of the hexaGenApp project structure, explaining the purpose and organization of each directory and key files.

---

## 📂 Repository Root

```
hexaGenApp/
├── .github/                    # GitHub configuration and workflows
├── docs/                       # Project documentation
├── fastlane/                   # CI/CD automation
├── hexagenapp/                 # Main Flutter application
├── LICENSES/                   # License files
├── .gitignore                  # Git ignore rules
├── .releaserc.yml              # Semantic release configuration
├── CHANGELOG.md                # Version history
├── LICENSE                     # MIT License
├── package.json                # Node.js dependencies (for tooling)
├── package-lock.json           # Node.js lock file
├── pnpm-lock.yaml              # PNPM lock file
├── README.md                   # Project overview
└── REUSE.toml                  # REUSE compliance configuration
```

---

## 🔧 `.github/` - GitHub Configuration

Automated workflows and community files for repository management.

### `ISSUE_TEMPLATE/`
- `bug-report.md` - Bug report template
- `feature-request.md` - Feature request template
- `documentation.md` - Documentation improvement template
- `question.md` - Question template
- `support.md` - Support request template
- `config.yml` - Issue template configuration

### `workflows/`
- `android-test.yml` - Android build and test automation
- `auto-assign.yml` - Auto-assign issues to team members
- `branch-name-check.yml` - Enforce branch naming conventions
- `ci.yml` - Continuous integration pipeline
- `ios-testflight.yml` - iOS TestFlight deployment
- `labeler.yml` - Auto-label PRs based on changed files
- `main-pr-protect.yml` - Main branch protection rules
- `pr-title-check.yml` - Enforce PR title conventions
- `release-pr-protect.yml` - Release branch protection
- `release.yml` - Automated release workflow
- `reuse-lint.yml` - License compliance checks
- `stale.yml` - Close stale issues/PRs

### Community Files
- `.commitlintrc.yml` - Commit message linting rules
- `auto_assign.yml` - Auto-assignment configuration
- `CODE_OF_CONDUCT.md` - Community guidelines
- `CODEOWNERS` - Code ownership definitions
- `CONTRIBUTING.md` - Contribution guidelines
- `dependabot.yml` - Dependency update automation
- `FUNDING.yml` - Sponsorship information
- `labeler.yml` - PR labeling rules
- `PULL_REQUEST_TEMPLATE.md` - PR template
- `SECURITY.md` - Security policy
- `SUPPORT.md` - Support resources

---

## 📖 `docs/` - Documentation

Comprehensive project documentation.

- `ARCHITECTURE.md` - System architecture and design patterns
- `BRANDING.md` - Visual identity and design system
- `BRANCH_STRATEGY.md` - Git branching workflow
- `CNAME` - Custom domain for GitHub Pages
- `CODE_OF_CONDUCT.md` - Community conduct guidelines
- `COMMIT_STRATEGY.md` - Commit message conventions
- `COMMUNITY.md` - Community resources
- `CONFIGURATION.md` - Configuration options
- `CONTACT.md` - Contact information
- `CONTRIBUTING.md` - How to contribute
- `DEVELOPMENT_GUIDE.md` - Development setup and workflow
- `FAQ.md` - Frequently asked questions
- `GETTING_STARTED.md` - Quick start guide
- `LABELLING_STRATEGY.md` - Issue and PR labeling system
- `PR_STRATEGY.md` - Pull request guidelines
- `PROJECT_BOARD.md` - Project management workflow
- `PROJECT_STRUCTURE.md` - This file
- `SECURITY.md` - Security policies
- `STYLE_GUIDE.md` - Code style guidelines
- `SUMMARY.md` - Project summary
- `SUPPORT.md` - Support channels

---

## 📱 `hexagenapp/` - Flutter Application

The main Flutter application source code.

### Root Files

- `pubspec.yaml` - Project dependencies and configuration
- `analysis_options.yaml` - Dart analyzer configuration
- `l10n.yaml` - Localization configuration
- `README.md` - Application-specific readme
- `.gitignore` - Git ignore rules
- `.metadata` - Flutter metadata

---

## 📂 `hexagenapp/lib/` - Application Source

### `main.dart`
Application entry point. Initializes:
- Background service
- Service locators
- App lifecycle management

### `l10n/` - Internationalization
- `app_en.arb` - English translations
- `app_tr.arb` - Turkish translations
- `app_localizations.dart` - Generated localization class
- `app_localizations_en.dart` - English implementation
- `app_localizations_tr.dart` - Turkish implementation

### `src/app.dart`
Root application widget with:
- Theme configuration
- Localization setup
- Navigation routing
- Material App initialization

---

## 🎯 `hexagenapp/lib/src/core/` - Core Functionality

### `at/` - AT Command Protocol
- `at.dart` - AT command builder and parser
- Implements: `VERSION`, `FREQ`, `SETRGB`, `RESET`, `FWUPDATE` commands
- Response parsing and validation

### `device/` - Device Management
- `device.dart` - `HexaTuneDeviceManager` singleton
- MIDI device scanning and connection
- Command transmission and response handling

### `error/` - Error Handling
- `error.dart` - Error code definitions (E001001-E001009)
- Error message mapping
- User-friendly error descriptions

### `logger/` - Logging System
- `logger.dart` - Logging infrastructure
- Categories: app, navigation, device, midi, ui, network, storage
- Levels: debug, info, warning, error, critical
- Configurable output and filtering

### `service/` - Core Services

#### `device_service.dart`
Singleton service managing:
- Device connection lifecycle
- Command ID generation (1-9999 cyclic)
- Command tracking and timeout
- Generation state management
- Background notifications

#### `log_service.dart`
Centralized logging service:
- In-memory log buffer (10,000 entries)
- Category and level filtering
- Real-time log streaming
- Export capabilities

#### `storage_service.dart`
Persistent storage service:
- Theme preference storage
- Operation history (max 50 entries)
- Last connected device info
- SharedPreferences wrapper

### `sysex/` - MIDI SysEx Protocol
- `sysex.dart` - SysEx message encoding/decoding
- UTF-8 to SysEx conversion
- USB MIDI packet framing
- Multi-packet message buffering

### `theme/` - Theme System
- `freq.dart` - Material Design 3 theme definitions
- Light, dark, and high-contrast variants
- Custom color schemes
- Typography configuration

### `utils/` - Utilities
- `theme.dart` - Text theme creation with custom fonts
- Helper functions

---

## 🖼️ `hexagenapp/lib/src/pages/` - UI Pages

### `main.dart`
Main navigation scaffold:
- Bottom navigation bar (5 tabs)
- Floating Action Button for generation control
- Device status indicator
- Background notification overlay
- Tab state management

### `generation.dart`
Frequency sequence builder:
- Add/remove frequency items (0-20 MHz)
- Duration setting (seconds)
- Drag-to-reorder items
- Repeat count configuration
- Real-time item status (pending/processing/completed/error)
- Max 64 items per sequence

### `history.dart`
Operation history viewer:
- Expandable history cards
- Timestamp, item count, repeat display
- Detailed frequency/duration list
- Regenerate functionality
- Auto-scroll to latest
- FIFO deletion at 50 entries

### `howtouse.dart`
Usage instructions page (placeholder):
- Coming soon content
- Will contain app usage tutorials

### `products.dart`
Product catalog page (placeholder):
- Coming soon content
- Will display hexaTune product lineup

### `settings.dart`
Settings and diagnostics:
- Theme mode selector (light/dark/high-contrast)
- Device information display
- Firmware version
- Real-time log monitor with filtering
- Auto-scroll toggle
- Clear logs action

---

## 🎨 `hexagenapp/assets/` - Static Assets

### `fonts/`
Custom fonts:
- **Inter**: Body text font
  - `Inter-Regular.ttf`
  - `Inter-Medium.ttf`
  - `Inter-SemiBold.ttf`
  - `Inter-Bold.ttf`
- **Rajdhani**: Display/heading font
  - `Rajdhani-Regular.ttf`
  - `Rajdhani-Medium.ttf`
  - `Rajdhani-SemiBold.ttf`
  - `Rajdhani-Bold.ttf`

### `icon/`
- `app_icon.png` - Application icon source

---

## 🤖 `hexagenapp/android/` - Android Platform

### `app/`
- `build.gradle.kts` - App-level Gradle configuration
- `local.properties` - Local SDK paths
- `src/` - Android-specific source code
  - `debug/` - Debug build configuration
  - `main/` - Main source set

### Root
- `build.gradle.kts` - Project-level Gradle
- `gradle.properties` - Gradle properties
- `settings.gradle.kts` - Gradle settings
- `gradle/wrapper/` - Gradle wrapper

---

## 🍎 `hexagenapp/ios/` - iOS Platform

### `Runner/`
- `AppDelegate.swift` - iOS app delegate
- `Info.plist` - iOS configuration
- `Assets.xcassets/` - iOS assets
  - `AppIcon.appiconset/` - App icon variants
- `Base.lproj/` - iOS localization base
- `Runner-Bridging-Header.h` - Swift/Objective-C bridge

### Root
- `Runner.xcodeproj/` - Xcode project configuration
- `Runner.xcworkspace/` - Xcode workspace
- `RunnerTests/` - iOS unit tests
- `exportOptions.plist` - Export configuration
- `Flutter/` - Flutter iOS engine

---

## 🐧 `hexagenapp/linux/` - Linux Platform

- `CMakeLists.txt` - CMake build configuration
- `runner/` - Linux runner application
- `flutter/` - Flutter Linux engine

---

## 🍏 `hexagenapp/macos/` - macOS Platform

### `Runner/`
- `AppDelegate.swift` - macOS app delegate
- `MainFlutterWindow.swift` - Main window
- `Info.plist` - macOS configuration
- `Configs/` - Build configurations
- `Assets.xcassets/` - macOS assets
- `*.entitlements` - App capabilities

### Root
- `Runner.xcodeproj/` - Xcode project
- `Runner.xcworkspace/` - Xcode workspace
- `RunnerTests/` - macOS unit tests
- `Flutter/` - Flutter macOS engine

---

## 🪟 `hexagenapp/windows/` - Windows Platform

### `runner/`
- `main.cpp` - Windows entry point
- `flutter_window.cpp/h` - Flutter window wrapper
- `win32_window.cpp/h` - Win32 window
- `Runner.rc` - Windows resources
- `runner.exe.manifest` - App manifest
- `resources/` - Windows resources

### Root
- `CMakeLists.txt` - CMake build configuration
- `flutter/` - Flutter Windows engine

---

## 🌐 `hexagenapp/web/` - Web Platform

- `index.html` - Web entry point
- `manifest.json` - PWA manifest
- `favicon.png` - Browser favicon
- `icons/` - PWA icons

---

## 🧪 `hexagenapp/test/` - Tests

- `widget_test.dart` - Widget tests
- Additional test files for unit and integration tests

---

## 🚀 `fastlane/` - Deployment Automation

- `Fastfile` - Fastlane configuration for automated builds and deployments

---

## 📜 `LICENSES/` - License Files

- `MIT.txt` - MIT License text for REUSE compliance

---

## 🔑 Key Files Explained

### `pubspec.yaml`
Defines:
- Flutter and Dart SDK constraints
- Dependencies (flutter_midi_command, shared_preferences, etc.)
- Assets (fonts, icons)
- Localization configuration

### `analysis_options.yaml`
Dart analyzer rules:
- Linting rules
- Code style enforcement
- Error/warning configuration

### `.releaserc.yml`
Semantic release configuration:
- Automated version bumping
- CHANGELOG generation
- Git tag creation

### `REUSE.toml`
License compliance configuration for REUSE specification

---

## 📊 File Statistics

**Total Structure:**
- ~100+ source files
- 6 platform targets (Android, iOS, Linux, macOS, Windows, Web)
- 2 languages (English, Turkish)
- 20+ documentation files
- 15+ GitHub workflows

**Code Distribution:**
- Dart: ~67%
- Platform-specific: ~20%
- Configuration: ~8%
- Documentation: ~5%

---

## 🔍 Navigation Tips

### Finding Features
- **Device connection**: `lib/src/core/device/device.dart`
- **Frequency generation**: `lib/src/pages/generation.dart`
- **Command protocol**: `lib/src/core/at/at.dart`
- **Theme configuration**: `lib/src/core/theme/freq.dart`
- **Service layer**: `lib/src/core/service/`

### Adding New Features
1. Services → `lib/src/core/service/`
2. UI Pages → `lib/src/pages/`
3. Core logic → `lib/src/core/`
4. Assets → `assets/`
5. Tests → `test/`

---

## 📞 Questions?

For questions about the project structure:
- **Email**: [info@hexatune.com](mailto:info@hexatune.com)
- **Issues**: [GitHub Issues](https://github.com/hTuneSys/hexaGenApp/issues)

---

Built by [hexaTune LLC](https://hexatune.com) · GitHub: [hTuneSys/hexaGenApp](https://github.com/hTuneSys/hexaGenApp) · License: [MIT](https://opensource.org/license/mit/)
