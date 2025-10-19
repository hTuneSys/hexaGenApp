// SPDX-FileCopyrightText: 2025 hexaTune LLC
// SPDX-License-Identifier: MIT

import 'package:flutter_test/flutter_test.dart';
import 'package:hexagenapp/src/core/error/error.dart';
import 'package:hexagenapp/src/core/service/log_service.dart';

void main() {
  group('Error Handling Tests', () {
    test('AppError codes are unique', () {
      final codes = AppError.values.map((e) => e.code).toSet();
      expect(codes.length, equals(AppError.values.length));
    });

    test('AppError fromCode works', () {
      final error = AppErrorExtension.fromCode('E001001');
      expect(error, equals(AppError.invalidCommand));
    });

    test('AppError fromCode returns null for unknown', () {
      final error = AppErrorExtension.fromCode('E999999');
      expect(error, isNull);
    });
  });

  group('LogService Tests', () {
    test('LogService is singleton', () {
      final logger1 = LogService();
      final logger2 = LogService();
      expect(logger1, same(logger2));
    });

    test('LogService logs messages', () {
      final logger = LogService();
      logger.info('Test message');
      final logs = logger.getRecentLogs(count: 10);
      expect(logs.any((log) => log.message == 'Test message'), isTrue);
    });

    test('LogService filters by level', () {
      final logger = LogService();
      logger.clearHistory();
      logger.debug('Debug message');
      logger.error('Error message');

      final errorLogs = logger.getRecentLogs(
        count: 100,
        minLevel: LogLevel.error,
      );
      expect(errorLogs.length, equals(1));
      expect(errorLogs.first.message, equals('Error message'));
    });
  });
}
