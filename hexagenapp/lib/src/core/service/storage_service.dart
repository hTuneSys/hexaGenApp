// SPDX-FileCopyrightText: 2025 hexaTune LLC
// SPDX-License-Identifier: MIT

import 'package:flutter/material.dart';
import 'package:hexagenapp/src/core/storage/local_storage.dart';

class StorageService extends ChangeNotifier {
  LocalStorage? _localStorage;
  String _themeMode = 'system';

  String get themeMode => _themeMode;

  bool get isInitialized => _localStorage != null;

  ThemeMode get themeModeValue {
    switch (_themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> initialize() async {
    _localStorage = await LocalStorage.initialize();
    _themeMode = _localStorage!.getThemeMode();
    notifyListeners();
  }

  Future<void> setThemeMode(String mode) async {
    if (_localStorage == null) return;
    await _localStorage!.setThemeMode(mode);
    _themeMode = mode;
    notifyListeners();
  }

  Future<void> saveOperation(Map<String, dynamic> operation) async {
    if (_localStorage == null) return;
    await _localStorage!.saveOperation(operation);
    notifyListeners();
  }

  List<Map<String, dynamic>> getSavedOperations() {
    if (_localStorage == null) return [];
    return _localStorage!.getSavedOperations();
  }
}

class StorageServiceProvider extends InheritedNotifier<StorageService> {
  const StorageServiceProvider({
    required super.notifier,
    required super.child,
    super.key,
  });

  static StorageService of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<StorageServiceProvider>();
    assert(provider != null, 'No StorageServiceProvider found in context');
    return provider!.notifier!;
  }
}
