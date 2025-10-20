// SPDX-FileCopyrightText: 2025 hexaTune LLC
// SPDX-License-Identifier: MIT

import 'package:flutter/foundation.dart';

/// Log levels for categorizing log messages
enum LogLevel {
  debug, // Detailed information for debugging
  info, // General informational messages
  warning, // Warning messages
  error, // Error messages
  critical, // Critical errors requiring immediate attention
}

/// Log categories for organizing logs
enum LogCategory {
  app, // Application lifecycle
  navigation, // Page navigation
  device, // Device connection/communication
  midi, // MIDI commands and responses
  ui, // UI events
  network, // Network operations (future)
  storage, // Storage operations (future)
}

/// Global logging service
class LogService extends ChangeNotifier {
  static final LogService _instance = LogService._internal();
  factory LogService() => _instance;

  LogService._internal();

  /// Debug mode - when false, only errors are logged for production
  bool _debugMode = true;
  bool get debugMode => _debugMode;
  set debugMode(bool value) {
    _debugMode = value;
    notifyListeners();
  }

  /// Log storage for potential crash reports (future use)
  final List<LogEntry> _logHistory = [];
  static const int _maxHistorySize = 500;

  /// Main logging method
  void log(
    String message, {
    LogLevel level = LogLevel.info,
    LogCategory category = LogCategory.app,
    Object? error,
    StackTrace? stackTrace,
  }) {
    // Store in history regardless of debug mode
    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      category: category,
      message: message,
      error: error,
      stackTrace: stackTrace,
    );

    _addToHistory(entry);

    // In production mode (debugMode = false), only log warnings and errors
    if (!debugMode && level.index < LogLevel.warning.index) {
      return;
    }

    // Format and print to console
    final prefix = _getPrefix(level, category);
    final formattedMessage = '$prefix $message';

    if (kDebugMode) {
      if (error != null) {
        debugPrint('$formattedMessage\nError: $error');
        if (stackTrace != null) {
          debugPrint('StackTrace:\n$stackTrace');
        }
      } else {
        debugPrint(formattedMessage);
      }
    }
  }

  /// Convenience methods for each log level
  void debug(String message, {LogCategory category = LogCategory.app}) {
    log(message, level: LogLevel.debug, category: category);
  }

  void info(String message, {LogCategory category = LogCategory.app}) {
    log(message, level: LogLevel.info, category: category);
  }

  void warning(
    String message, {
    LogCategory category = LogCategory.app,
    Object? error,
  }) {
    log(message, level: LogLevel.warning, category: category, error: error);
  }

  void error(
    String message, {
    LogCategory category = LogCategory.app,
    Object? error,
    StackTrace? stackTrace,
  }) {
    log(
      message,
      level: LogLevel.error,
      category: category,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void critical(
    String message, {
    LogCategory category = LogCategory.app,
    Object? error,
    StackTrace? stackTrace,
  }) {
    log(
      message,
      level: LogLevel.critical,
      category: category,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Category-specific convenience methods
  void navigation(String message) {
    info(message, category: LogCategory.navigation);
  }

  void device(String message, {LogLevel level = LogLevel.info}) {
    log(message, level: level, category: LogCategory.device);
  }

  void midi(String message, {LogLevel level = LogLevel.debug}) {
    log(message, level: level, category: LogCategory.midi);
  }

  void ui(String message) {
    debug(message, category: LogCategory.ui);
  }

  /// Get log prefix based on level and category
  String _getPrefix(LogLevel level, LogCategory category) {
    final levelIcon = _getLevelIcon(level);
    final timestamp = DateTime.now().toIso8601String().substring(
      11,
      23,
    ); // HH:mm:ss.SSS
    final categoryName = category.name.toUpperCase().padRight(10);
    return '[$timestamp] $levelIcon [$categoryName]';
  }

  /// Get icon for log level
  String _getLevelIcon(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '🔍';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
      case LogLevel.critical:
        return '🚨';
    }
  }

  /// Add entry to history with size limit
  void _addToHistory(LogEntry entry) {
    _logHistory.add(entry);
    if (_logHistory.length > _maxHistorySize) {
      _logHistory.removeAt(0);
    }
    notifyListeners();
  }

  /// Get recent logs (for future crash reporting)
  List<LogEntry> getRecentLogs({int count = 100, LogLevel? minLevel}) {
    var logs = _logHistory;

    if (minLevel != null) {
      logs = logs
          .where((entry) => entry.level.index >= minLevel.index)
          .toList();
    }

    return logs.length <= count ? logs : logs.sublist(logs.length - count);
  }

  /// Get logs by category
  List<LogEntry> getLogsByCategory(LogCategory category, {int count = 50}) {
    final filtered = _logHistory
        .where((entry) => entry.category == category)
        .toList();
    return filtered.length <= count
        ? filtered
        : filtered.sublist(filtered.length - count);
  }

  /// Clear log history
  void clearHistory() {
    _logHistory.clear();
    notifyListeners();
  }

  /// Export logs as string (for crash reports)
  String exportLogs({int? lastN, LogLevel? minLevel}) {
    final logs = getRecentLogs(
      count: lastN ?? _maxHistorySize,
      minLevel: minLevel,
    );
    final buffer = StringBuffer();

    buffer.writeln('=== HexaGen Log Export ===');
    buffer.writeln('Exported at: ${DateTime.now().toIso8601String()}');
    buffer.writeln('Total entries: ${logs.length}');
    buffer.writeln('Debug mode: $debugMode');
    buffer.writeln('================================\n');

    for (final entry in logs) {
      buffer.writeln(entry.toString());
      if (entry.error != null) {
        buffer.writeln('  Error: ${entry.error}');
      }
      if (entry.stackTrace != null) {
        buffer.writeln(
          '  Stack: ${entry.stackTrace.toString().split('\n').take(3).join('\n  ')}',
        );
      }
      buffer.writeln();
    }

    return buffer.toString();
  }
}

/// Log entry for storage
class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final LogCategory category;
  final String message;
  final Object? error;
  final StackTrace? stackTrace;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.category,
    required this.message,
    this.error,
    this.stackTrace,
  });

  @override
  String toString() {
    final levelStr = level.name.toUpperCase();
    return '$levelStr - $message';
  }
}

/// Global logger instance
final logger = LogService();
