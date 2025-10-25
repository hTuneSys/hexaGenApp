<!--
SPDX-FileCopyrightText: 2025 hexaTune LLC
SPDX-License-Identifier: MIT
-->

# Style Guide

This style guide ensures consistency across the hexaGenApp codebase by outlining formatting rules, naming conventions, and Dart/Flutter-specific practices.

---

## 📋 Table of Contents

- [General Principles](#general-principles)
- [File Organization](#file-organization)
- [Naming Conventions](#naming-conventions)
- [Code Formatting](#code-formatting)
- [Dart Language Conventions](#dart-language-conventions)
- [Flutter Widget Conventions](#flutter-widget-conventions)
- [Comments and Documentation](#comments-and-documentation)
- [Error Handling](#error-handling)
- [State Management](#state-management)
- [Testing](#testing)

---

## 🎯 General Principles

### Code Quality
- Write **clear, readable, maintainable** code
- Prefer **simplicity** over cleverness
- Follow **DRY** (Don't Repeat Yourself) principle
- Use **meaningful names** that convey intent
- Keep functions **small and focused** (single responsibility)

### Consistency
- Follow existing patterns in the codebase
- Match the style of surrounding code
- Use the same approach for similar problems

### Performance
- Avoid premature optimization
- Profile before optimizing
- Consider memory usage in mobile contexts

---

## 📁 File Organization

### File Header
Every file must include SPDX license headers:

```dart
// SPDX-FileCopyrightText: 2025 hexaTune LLC
// SPDX-License-Identifier: MIT
```

### Import Order
Organize imports in the following order with blank lines between groups:

1. Dart SDK imports
2. Flutter framework imports
3. Third-party package imports
4. Local project imports (using relative paths from `lib/`)

```dart
// SPDX-FileCopyrightText: 2025 hexaTune LLC
// SPDX-License-Identifier: MIT

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import 'package:hexagenapp/src/core/device/device.dart';
import 'package:hexagenapp/src/core/at/at.dart';
import 'package:hexagenapp/l10n/app_localizations.dart';
```

### File Structure
Files should follow this general structure:

1. License header
2. Imports
3. Constants (top-level or class-level)
4. Type definitions (enums, typedefs)
5. Classes/functions
6. Private helpers at the bottom

---

## 🏷️ Naming Conventions

### General Rules
- Use **descriptive names** that convey purpose
- Avoid abbreviations unless widely recognized (e.g., `Hz`, `MIDI`)
- Use **English** for all identifiers

### Case Styles

#### UpperCamelCase
- Classes: `DeviceService`, `HexaTuneDeviceManager`
- Enums: `ItemStatus`, `LogCategory`
- Type aliases: `ItemStatusCallback`
- Extensions: `StringExtension`

#### lowerCamelCase
- Variables: `currentDevice`, `deviceVersion`
- Functions/methods: `initialize()`, `connectToDevice()`
- Parameters: `onItemCountChanged`, `deviceId`
- Non-constant fields: `_isInitialized`, `_deviceManager`

#### lowercase_with_underscores
- Package names: `hexagenapp`
- Directories: `core`, `pages`, `device`
- File names: `device_service.dart`, `log_service.dart`

#### SCREAMING_CAPS
- Constants: `_maxItems`, `_maxId`, `_maxNotifications`
- Enum values use lowerCamelCase: `ItemStatus.pending`

### Private Members
Prefix with underscore for private fields, methods, and classes:

```dart
class DeviceService {
  // Private fields
  MidiDevice? _currentDevice;
  int _nextId = 1;
  
  // Private methods
  int _generateId() { ... }
  void _trackCommand() { ... }
  
  // Public interface
  bool get isConnected => ...;
  Future<void> initialize() async { ... }
}
```

### Booleans
Use positive, question-like names:

```dart
bool isConnected;       // ✅ Good
bool notDisconnected;   // ❌ Bad

bool hasUnreadNotifications;  // ✅ Good
bool noNotifications;         // ❌ Bad

bool _waitingForResponse;  // ✅ Good
bool _notReady;            // ❌ Bad
```

### Collections
Use plural names:

```dart
final List<NotificationItem> _notifications = [];
final Map<int, Timer> _commandTimers = {};
final Set<String> deviceIds = {};
```

---

## 🎨 Code Formatting

### Automated Formatting
Always run `dart format .` before committing. The project follows official Dart formatting conventions.

### Line Length
- Maximum **80 characters** per line (Dart standard)
- Break long lines at logical points

### Indentation
- Use **2 spaces** (not tabs)
- Flutter/Dart standard indentation

### Trailing Commas
Use trailing commas for better formatting and diffs:

```dart
// ✅ Good - Allows formatter to work optimally
Widget build(BuildContext context) {
  return Column(
    children: [
      Text('Hello'),
      Button('Click me'),
    ],
  );
}

// ❌ Bad - No trailing comma, single line
Widget build(BuildContext context) {
  return Column(children: [Text('Hello'), Button('Click me')]);
}
```

### Braces
Always use braces for control flow, even single-line statements:

```dart
// ✅ Good
if (isConnected) {
  disconnect();
}

// ❌ Bad
if (isConnected) disconnect();
```

### Spacing
- Space after control keywords: `if (condition)`, `for (item in items)`
- No space for function calls: `initialize()`, `connect(device)`
- Space around operators: `a + b`, `x == y`, `value ?? defaultValue`

---

## 🎯 Dart Language Conventions

### Type Annotations
Use explicit types for public APIs, optional for local variables:

```dart
// ✅ Good - Public API with explicit types
Future<void> initialize() async { ... }
String? get deviceVersion => _deviceVersion;

// ✅ Good - Local variable with inference
final device = await scanForDevice();
var count = items.length;

// ❌ Bad - Missing return type
connectDevice() async { ... }
```

### Null Safety
Embrace null safety features:

```dart
// Use nullable types
String? _deviceVersion;

// Use null-aware operators
final version = _deviceVersion ?? 'Unknown';
final length = items?.length ?? 0;

// Use null assertion only when certain
final device = currentDevice!; // Only if guaranteed non-null

// Prefer null checks
if (_currentDevice != null) {
  final device = _currentDevice!;
  useDevice(device);
}
```

### Async/Await
Prefer `async`/`await` over raw `Future` chaining:

```dart
// ✅ Good
Future<void> initialize() async {
  await loadDevices();
  await connectToDevice();
  await fetchVersion();
}

// ❌ Bad
Future<void> initialize() {
  return loadDevices()
    .then((_) => connectToDevice())
    .then((_) => fetchVersion());
}
```

### Constants
Use `const` for compile-time constants:

```dart
// ✅ Good
const Duration timeout = Duration(seconds: 5);
const int maxItems = 64;
const Widget placeholder = Text('Loading...');

// Use static const for class constants
class GenerationPage extends StatefulWidget {
  static const int _maxItems = 64;
  static const double _minHz = 0;
  static const double _maxHz = 20_000_000;
}
```

### Collections
Use collection literals and spread operators:

```dart
// ✅ Good
final items = <String>[];
final map = <String, int>{};
final combined = [...list1, ...list2];

// ❌ Bad
final items = List<String>();
final map = Map<String, int>();
```

### Enums
Use enhanced enums when possible (Dart 2.17+):

```dart
enum ItemStatus { 
  pending, 
  processing, 
  completed, 
  error,
}

enum LogCategory { 
  app, 
  navigation, 
  device, 
  midi, 
  ui, 
  network, 
  storage,
}
```

---

## 📱 Flutter Widget Conventions

### Widget Structure
Follow this structure for widget classes:

```dart
class MyWidget extends StatefulWidget {
  // 1. Constants
  static const int maxValue = 100;
  
  // 2. Final fields (constructor parameters)
  final String title;
  final VoidCallback? onPressed;
  
  // 3. Constructor
  const MyWidget({
    super.key,
    required this.title,
    this.onPressed,
  });
  
  // 4. createState
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  // 1. Private fields
  int _counter = 0;
  
  // 2. Lifecycle methods
  @override
  void initState() {
    super.initState();
  }
  
  @override
  void dispose() {
    super.dispose();
  }
  
  // 3. Build method
  @override
  Widget build(BuildContext context) {
    return Container();
  }
  
  // 4. Helper methods
  void _incrementCounter() {
    setState(() => _counter++);
  }
}
```

### Widget Keys
Use keys for widgets in lists or when identity matters:

```dart
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListTile(
      key: ValueKey(items[index].id),  // ✅ Good
      title: Text(items[index].name),
    );
  },
)
```

### BuildContext
Pass `BuildContext` explicitly, don't store in fields:

```dart
// ✅ Good
void _showDialog(BuildContext context) {
  showDialog(context: context, builder: ...);
}

// ❌ Bad
late BuildContext _context;
void initState() {
  _context = context; // Context can become invalid
}
```

### Extract Widgets
Extract complex widget trees into separate methods or widgets:

```dart
// ✅ Good - Small build method
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: _buildAppBar(),
    body: _buildBody(),
  );
}

Widget _buildAppBar() {
  return AppBar(title: Text('Title'));
}

// Or extract to a separate widget for better performance
class MyAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(title: Text('Title'));
  }
}
```

---

## 💬 Comments and Documentation

### Documentation Comments
Use `///` for public APIs:

```dart
/// Initializes the device service.
/// 
/// This should be called once during app startup.
/// Returns a [Future] that completes when initialization is done.
Future<void> initialize() async { ... }

/// The currently connected MIDI device, or null if disconnected.
MidiDevice? get currentDevice => _currentDevice;
```

### Implementation Comments
Use `//` for implementation notes:

```dart
// Generate next sequential ID (1-9999, wraps around)
int _generateId() {
  final id = _nextId;
  _nextId = _nextId % _maxId + 1;  // Wrap around at max
  return id;
}
```

### Comment Style
- Write **complete sentences** with proper punctuation
- Explain **why**, not what (code shows what)
- Keep comments **up to date** with code changes
- Remove commented-out code (use version control)

```dart
// ✅ Good - Explains why
// Use a timer to prevent blocking the UI thread
await Future.delayed(Duration(milliseconds: 100));

// ❌ Bad - States the obvious
// Set counter to zero
_counter = 0;
```

### TODO Comments
Format consistently for easy searching:

```dart
// TODO(username): Add retry logic for failed connections
// FIXME: Memory leak when disposing multiple times
// HACK: Workaround for flutter_midi_command issue #123
```

---

## ⚠️ Error Handling

### Exception Types
Use appropriate exception types:

```dart
// Use built-in exceptions
throw ArgumentError('Device ID cannot be null');
throw StateError('Service not initialized');
throw FormatException('Invalid AT command format');

// Define custom exceptions for domain-specific errors
class DeviceNotConnectedException implements Exception {
  final String message;
  DeviceNotConnectedException(this.message);
  
  @override
  String toString() => 'DeviceNotConnectedException: $message';
}
```

### Try-Catch
Handle exceptions at appropriate levels:

```dart
// ✅ Good - Handle specific errors
try {
  await connectToDevice(device);
} on DeviceNotConnectedException catch (e) {
  logger.error('Failed to connect: $e', category: LogCategory.device);
  showErrorDialog(context, e.message);
} catch (e) {
  logger.critical('Unexpected error: $e', category: LogCategory.app);
  rethrow;
}
```

### Error Return Values
Use nullable types or Result types for expected failures:

```dart
// ✅ Good - Nullable for expected absence
String? findDeviceById(String id) { ... }

// ✅ Good - Result type for success/failure
Result<Device, Error> connectDevice(String id) { ... }
```

---

## 🔄 State Management

### ChangeNotifier Pattern
Follow singleton pattern for services:

```dart
class DeviceService extends ChangeNotifier {
  // Singleton instance
  static final DeviceService _instance = DeviceService._internal();
  factory DeviceService() => _instance;
  DeviceService._internal();
  
  // Private state
  bool _isConnected = false;
  
  // Public getters
  bool get isConnected => _isConnected;
  
  // Methods that modify state call notifyListeners
  void connect() {
    _isConnected = true;
    notifyListeners();
  }
}
```

### setState Usage
Keep `setState` calls minimal and focused:

```dart
// ✅ Good - Only update what changed
void _incrementCounter() {
  setState(() {
    _counter++;
  });
}

// ❌ Bad - Heavy computation in setState
void _updateData() {
  setState(() {
    _data = processLargeDataset();  // Move outside setState
    _filtered = filterData(_data);
  });
}

// ✅ Better
Future<void> _updateData() async {
  final processed = await processLargeDataset();
  final filtered = filterData(processed);
  setState(() {
    _data = processed;
    _filtered = filtered;
  });
}
```

---

## 🧪 Testing

### Test File Naming
Match source file names with `_test.dart` suffix:

```
lib/src/core/device/device.dart
test/core/device/device_test.dart
```

### Test Structure
Use `group` and descriptive test names:

```dart
void main() {
  group('DeviceService', () {
    test('should initialize successfully', () {
      // Arrange
      final service = DeviceService();
      
      // Act
      service.initialize();
      
      // Assert
      expect(service.isInitialized, isTrue);
    });
    
    test('should generate sequential IDs', () {
      final service = DeviceService();
      final id1 = service.generateId();
      final id2 = service.generateId();
      expect(id2, equals(id1 + 1));
    });
  });
}
```

---

## 🔍 Code Analysis

### Linting
The project uses `flutter_lints` with custom rules in `analysis_options.yaml`.

Run analysis before committing:

```bash
flutter analyze
```

### Common Lint Rules
- `prefer_const_constructors` - Use const when possible
- `prefer_final_fields` - Mark fields final if not reassigned
- `avoid_print` - Use logging instead of print()
- `use_key_in_widget_constructors` - Add key parameter to widgets

---

## ✅ Pre-Commit Checklist

Before committing code:

1. ✅ Run `dart format .`
2. ✅ Run `flutter analyze` (no errors)
3. ✅ Run `flutter test` (all tests pass)
4. ✅ Add SPDX license headers to new files
5. ✅ Update documentation if needed
6. ✅ Follow commit message conventions
7. ✅ Remove debug code and console logs

---

## 📚 Additional Resources

- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Flutter Style Guide](https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Flutter Best Practices](https://docs.flutter.dev/perf/best-practices)

---

Consistent style improves collaboration and makes onboarding easier. Stick to this guide for clean, professional code.

---

## 📞 Questions?

For style-related questions:
- **Email**: [info@hexatune.com](mailto:info@hexatune.com)
- **Issues**: [GitHub Issues](https://github.com/hTuneSys/hexaGenApp/issues)

---

Built by [hexaTune LLC](https://hexatune.com) · GitHub: [hTuneSys/hexaGenApp](https://github.com/hTuneSys/hexaGenApp) · License: [MIT](https://opensource.org/license/mit/)
