// SPDX-FileCopyrightText: 2025 hexaTune LLC
// SPDX-License-Identifier: MIT

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const String _themeKey = 'theme_mode';

  final SharedPreferences _prefs;

  LocalStorage(this._prefs);

  static Future<LocalStorage> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorage(prefs);
  }

  /// Get theme mode: 'system', 'light', or 'dark'
  /// Default is 'system'
  String getThemeMode() {
    return _prefs.getString(_themeKey) ?? 'system';
  }

  /// Set theme mode: 'system', 'light', or 'dark'
  Future<bool> setThemeMode(String mode) async {
    return await _prefs.setString(_themeKey, mode);
  }
}
