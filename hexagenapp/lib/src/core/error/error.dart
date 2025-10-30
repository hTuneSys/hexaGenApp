// SPDX-FileCopyrightText: 2025 hexaTune LLC
// SPDX-License-Identifier: MIT

/// Application error types with corresponding error codes
enum AppError {
  invalidCommand,
  ddsBusy,
  invalidUtf8,
  invalidSysEx,
  invalidDataLength,
  paramCount,
  paramValue,
  notAQuery,
  unknownCommand,
  operationStepsFull,
}

/// Extension to get error code for each error type
extension AppErrorExtension on AppError {
  String get code {
    switch (this) {
      // Command errors
      case AppError.invalidCommand:
        return 'E001001';
      case AppError.ddsBusy:
        return 'E001002';
      case AppError.invalidUtf8:
        return 'E001003';
      case AppError.invalidSysEx:
        return 'E001004';
      case AppError.invalidDataLength:
        return 'E001005';
      case AppError.paramCount:
        return 'E001006';
      case AppError.paramValue:
        return 'E001007';
      case AppError.notAQuery:
        return 'E001008';
      case AppError.unknownCommand:
        return 'E001009';
      case AppError.operationStepsFull:
        return 'E001010';
    }
  }

  /// Parse error code from string (e.g., "E001001" -> AppError.invalidCommand)
  static AppError? fromCode(String code) {
    for (final error in AppError.values) {
      if (error.code == code) return error;
    }
    return null;
  }

  /// Get localized error message
  String getLocalizedMessage(dynamic localizations) {
    switch (this) {
      case AppError.invalidCommand:
        return localizations.invalidCommand;
      case AppError.ddsBusy:
        return localizations.ddsBusy;
      case AppError.invalidUtf8:
        return localizations.invalidUtf8;
      case AppError.invalidSysEx:
        return localizations.invalidSysEx;
      case AppError.invalidDataLength:
        return localizations.invalidDataLength;
      case AppError.paramCount:
        return localizations.paramCount;
      case AppError.paramValue:
        return localizations.paramValue;
      case AppError.notAQuery:
        return localizations.notAQuery;
      case AppError.unknownCommand:
        return localizations.unknownCommand;
      case AppError.operationStepsFull:
        return localizations.operationStepsFull;
    }
  }
}
