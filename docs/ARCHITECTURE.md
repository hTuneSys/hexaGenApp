<!--
SPDX-FileCopyrightText: 2025 hexaTune LLC
SPDX-License-Identifier: MIT
-->

# 🏗️ hexaGenApp Architecture

## Overview

hexaGenApp is a Flutter-based mobile frequency generator application designed to communicate with hexaTune hardware devices via MIDI protocol. The application enables users to create, manage, and execute frequency generation sequences with real-time status monitoring.

---

## Technology Stack

### Core Technologies
- **Framework:** Flutter 3.x
- **Language:** Dart ^3.9.2
- **Architecture:** Material Design 3
- **Platforms:** Android, iOS, Linux, macOS, Windows, Web

### Key Dependencies
- `flutter_midi_command` (^2.0.4) - MIDI device communication
- `shared_preferences` (^2.3.4) - Local data persistence
- `flutter_background_service` (^6.0.0) - Background task execution
- `storybook_flutter` (^0.16.1) - UI component development

---

## Application Architecture

### High-Level Structure

```
hexaGenApp/
├── lib/
│   ├── main.dart                    # Application entry point
│   ├── l10n/                        # Internationalization (en, tr)
│   └── src/
│       ├── app.dart                 # Root application widget
│       ├── core/                    # Core functionality
│       │   ├── at/                  # AT command protocol
│       │   ├── device/              # Device management
│       │   ├── error/               # Error handling
│       │   ├── logger/              # Logging system
│       │   ├── service/             # Core services
│       │   ├── sysex/               # SysEx message handling
│       │   └── theme/               # Theme configuration
│       └── pages/                   # UI pages
│           ├── generation.dart      # Frequency sequence builder
│           ├── history.dart         # Operation history
│           ├── howtouse.dart        # Usage instructions
│           ├── main.dart            # Main navigation
│           ├── products.dart        # Product catalog
│           └── settings.dart        # Settings & device info
```

---

## Core Components

### 1. Service Layer (`lib/src/core/service/`)

#### DeviceService (Singleton)
Manages hexaTune device lifecycle and communication.

**Key Responsibilities:**
- Device connection state management
- MIDI communication orchestration
- Command ID generation (1-9999, cyclic)
- Command tracking with timeout handling
- Notification management during generation
- Status polling for device availability

**State Management:**
- Connection status: `disconnected` → `connecting` → `connected` → `disconnected`
- Generation status: `idle` → `generating` → `idle`
- Error states with automatic recovery

#### StorageService
Handles persistent data storage.

**Managed Data:**
- Theme preferences (light/dark/high-contrast)
- Operation history (max 50 entries, FIFO)
- Last connected device information

#### LogService
Comprehensive logging system with filtering capabilities.

**Log Categories:**
- `app` - Application lifecycle
- `navigation` - Page navigation
- `device` - Device operations
- `midi` - MIDI communication
- `ui` - User interface events
- `network` - Network operations
- `storage` - Data persistence

**Log Levels:**
- `debug` → `info` → `warning` → `error` → `critical`

---

### 2. Device Communication Layer

#### HexaTuneDeviceManager (`lib/src/core/device/device.dart`)

Provides low-level MIDI device interaction.

**Capabilities:**
- Device scanning and discovery
- Connection establishment
- AT command transmission via SysEx
- Response listener registration
- Automatic disconnect handling

**MIDI Protocol:**
- Uses USB MIDI packets (4 bytes per packet)
- SysEx messages: `F0 [data...] F7`
- Command format: UTF-8 encoded AT commands

#### AT Command Protocol (`lib/src/core/at/at.dart`)

Implements hexaTune AT command specification.

**Command Types:**

| Command | Format | Parameters | Response |
|---------|--------|------------|----------|
| `VERSION` | `AT+VERSION=id` | Command ID | `AT+VERSION=id#version` |
| `FREQ` | `AT+FREQ=id#freq#duration` | Frequency (0-20MHz), Duration (seconds) | `AT+DONE=id` or `AT+ERROR=id#code` |
| `SETRGB` | `AT+SETRGB=id#r#g#b` | RGB values (0-255) | `AT+DONE=id` |
| `RESET` | `AT+RESET=id` | Command ID | `AT+DONE=id` |
| `FWUPDATE` | `AT+FWUPDATE=id` | Command ID | `AT+DONE=id` |

**Response Parsing:**
- Success: `AT+DONE=id`
- Error: `AT+ERROR=id#code` (codes: E001001-E001009)
- Status: `AT+STATUS=id#AVAILABLE|GENERATING`

#### SysEx Handler (`lib/src/core/sysex/sysex.dart`)

Manages System Exclusive MIDI message encoding/decoding.

**Features:**
- UTF-8 string → SysEx byte conversion
- USB MIDI packet framing (4-byte alignment)
- Multi-packet message buffering
- F0/F7 marker insertion/validation

**Packet Structure:**
```
[Cable#/CIN, Data1, Data2, Data3]
```
- CIN codes: 0x04 (SysEx start), 0x07 (SysEx end), 0x05/0x06 (continue)

---

### 3. User Interface Layer

#### Main Navigation (`lib/src/pages/main.dart`)

Primary application scaffold with bottom navigation.

**Navigation Tabs:**
1. **Generation** - Frequency sequence builder
2. **History** - Past operations
3. **Products** - Product catalog (placeholder)
4. **How to Use** - Instructions (placeholder)
5. **Settings** - Configuration & logs

**Features:**
- Floating Action Button (FAB) for start/stop generation
- Notification overlay during background generation
- Device status indicator in app bar
- Automatic tab state preservation

#### Generation Page (`lib/src/pages/generation.dart`)

Interactive frequency sequence builder.

**Capabilities:**
- Add frequency items (0-20 MHz range validation)
- Set duration per item (seconds)
- Reorder items via drag-and-drop
- Delete individual items
- Set repeat count
- Real-time item status tracking:
  - `pending` (gray)
  - `processing` (blue)
  - `completed` (green)
  - `error` (red)

**Sequence Limits:**
- Maximum 64 items per sequence
- Minimum 1 item to start generation

**Execution Flow:**
1. Validate sequence
2. Send items sequentially via `FREQ` command
3. Wait for `AT+DONE` or `AT+ERROR` response
4. Update item status
5. Proceed to next item
6. Save to history on completion
7. Send `RESET` on user cancellation

#### History Page (`lib/src/pages/history.dart`)

Operation history with regeneration capability.

**Features:**
- Expandable cards showing:
  - Execution timestamp
  - Total items in sequence
  - Repeat count
  - Detailed frequency/duration list
- "Regenerate" button to replay past sequences
- Automatic scrolling to latest entry
- Maximum 50 entries (FIFO deletion)

#### Settings Page (`lib/src/pages/settings.dart`)

Configuration and diagnostics.

**Sections:**
1. **Theme Selector** - Light/Dark/High-Contrast modes
2. **Device Information** - Connection status, firmware version
3. **Log Monitor** - Real-time log viewer with:
   - Category filtering
   - Level filtering
   - Auto-scroll toggle
   - Clear logs action

---

### 4. Theme System (`lib/src/core/theme/freq.dart`)

Material Design 3 implementation with custom color scheme.

**Color Palette:**
- **Primary:** Yellow (`#FFC107`)
- **Secondary:** Cyan (`#00BCD4`)
- **Tertiary:** Purple (`#9C27B0`)
- **Background:** Dynamic based on mode

**Variants:**
- Light mode - High brightness
- Dark mode - OLED-friendly
- High contrast - Accessibility-focused

**Typography:**
- Font families: `Inter`, `Rajdhani`
- Adaptive sizing for platform consistency

---

## Data Flow

### Frequency Generation Workflow

```
User Input (Generation Page)
    ↓
Validation & Sequence Building
    ↓
DeviceService.startGeneration()
    ↓
Background Service Notification
    ↓
For each item in sequence:
    ├── Build AT+FREQ command
    ├── Encode to SysEx
    ├── Send via MIDI
    ├── Wait for response
    ├── Update item status
    └── Log result
    ↓
Complete sequence
    ↓
Save to history (StorageService)
    ↓
Update UI
```

### Device Connection Flow

```
User Action: Scan Devices
    ↓
HexaTuneDeviceManager.scanDevices()
    ↓
Display available MIDI devices
    ↓
User Selection
    ↓
HexaTuneDeviceManager.connectToDevice()
    ↓
Setup response listener
    ↓
Send AT+VERSION command
    ↓
Receive firmware version
    ↓
DeviceService.setConnected()
    ↓
Enable generation features
```

---

## Error Handling

### Error Code Mapping (`lib/src/core/error/error.dart`)

| Code | Description |
|------|-------------|
| E001001 | Invalid command format |
| E001002 | Unknown command |
| E001003 | Invalid parameter count |
| E001004 | Invalid parameter value |
| E001005 | Command execution failed |
| E001006 | Device busy |
| E001007 | Device not ready |
| E001008 | Hardware error |
| E001009 | Timeout |

### Recovery Strategies

- **Connection Lost:** Auto-reconnect attempt with exponential backoff
- **Command Timeout:** Retry up to 3 times, then fail item
- **Invalid Response:** Log error, continue to next item
- **Device Busy:** Poll status, wait until available

---

## Background Service

### Implementation (`lib/main.dart`)

Uses `flutter_background_service` for persistent generation execution.

**Lifecycle:**
1. Initialize on app start
2. Register background entry point
3. Maintain MIDI connection during background
4. Show persistent notification
5. Communicate with foreground via IsolateNameServer

**Permissions Required:**
- Android: `FOREGROUND_SERVICE`, `WAKE_LOCK`
- iOS: Background modes (audio, fetch)

---

## Localization

### Supported Languages
- English (en) - Default
- Turkish (tr)

### Implementation (`lib/l10n/`)
- ARB format for translations
- Auto-generated classes via `flutter_localizations`
- Hot-reload support during development

---

## State Management

### Approach
- **Service-based state:** Singleton services with `ChangeNotifier`
- **Local state:** `StatefulWidget` for UI-specific state
- **Persistent state:** `SharedPreferences` for user preferences

### Why No State Management Library?
- Application complexity doesn't warrant Redux/BLoC overhead
- Service layer provides sufficient reactivity
- Keeps dependency tree minimal

---

## Testing Strategy

### Current Coverage
- Widget tests for main UI components (`test/widget_test.dart`)

### Recommended Additions
- Unit tests for AT command parsing
- Integration tests for MIDI communication
- Mock device for CI/CD testing
- Golden tests for UI consistency

---

## Performance Considerations

### Optimizations
- Command ID pooling to avoid integer overflow
- Log buffer with size limit (10,000 entries)
- History cap at 50 entries
- Debounced UI updates during generation
- Lazy loading for history list

### Memory Management
- Dispose MIDI listeners on disconnect
- Clear command tracking map on completion
- Automatic log rotation

---

## Security

### Best Practices
- No hardcoded secrets
- USB MIDI only (no network exposure)
- Input validation for all AT commands
- Sanitized error messages to users

---

## Future Architecture Improvements

### Potential Enhancements
1. **Dependency Injection:** Consider `get_it` for service management
2. **State Management:** Migrate to `riverpod` if complexity grows
3. **Testing:** Add comprehensive test suite
4. **Analytics:** Integrate Firebase Analytics for usage insights
5. **Crash Reporting:** Add Sentry or Firebase Crashlytics
6. **OTA Updates:** Implement in-app firmware update UI
7. **Cloud Sync:** Optional history backup to cloud storage

---

## 📬 Questions?

Contact the team at **[info@hexatune.com](mailto:info@hexatune.com)** or open an issue.

---

Built by [hexaTune LLC](https://hexatune.com) · GitHub: [hTuneSys/hexaGenApp](https://github.com/hTuneSys/hexaGenApp) · License: [MIT](https://opensource.org/license/mit/)
