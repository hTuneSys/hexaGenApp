// SPDX-FileCopyrightText: 2025 hexaTune LLC
// SPDX-License-Identifier: MIT

import 'dart:convert';
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

  static const String _operationsKey = 'saved_operations';
  static const int _maxOperations = 50;

  /// Save operation
  Future<bool> saveOperation(Map<String, dynamic> operation) async {
    final operations = getSavedOperations();
    operations.add(operation);
    if (operations.length > _maxOperations) {
      operations.removeAt(0);
    }
    final jsonList = operations.map((op) => jsonEncode(op)).toList();
    return await _prefs.setStringList(_operationsKey, jsonList);
  }

  /// Get saved operations
  List<Map<String, dynamic>> getSavedOperations() {
    final jsonList = _prefs.getStringList(_operationsKey) ?? [];
    return jsonList
        .map((jsonStr) => jsonDecode(jsonStr) as Map<String, dynamic>)
        .toList();
  }
}
