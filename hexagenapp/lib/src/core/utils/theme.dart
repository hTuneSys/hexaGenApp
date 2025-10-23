// SPDX-FileCopyrightText: 2025 hexaTune LLC
// SPDX-License-Identifier: MIT

import 'package:flutter/material.dart';
import 'package:hexagenapp/src/core/service/log_service.dart';

TextTheme createTextTheme(BuildContext context) {
  final base = Theme.of(context).textTheme;

  final textTheme = base.copyWith(
    bodyLarge: base.bodyLarge?.copyWith(fontFamily: 'Inter'),
    bodyMedium: base.bodyMedium?.copyWith(fontFamily: 'Inter'),
    bodySmall: base.bodySmall?.copyWith(fontFamily: 'Inter'),
    labelLarge: base.labelLarge?.copyWith(fontFamily: 'Inter'),
    labelMedium: base.labelMedium?.copyWith(fontFamily: 'Inter'),
    labelSmall: base.labelSmall?.copyWith(fontFamily: 'Inter'),
    displayLarge: base.displayLarge?.copyWith(fontFamily: 'Rajdhani'),
    displayMedium: base.displayMedium?.copyWith(fontFamily: 'Rajdhani'),
    displaySmall: base.displaySmall?.copyWith(fontFamily: 'Rajdhani'),
    headlineLarge: base.headlineLarge?.copyWith(fontFamily: 'Rajdhani'),
    headlineMedium: base.headlineMedium?.copyWith(fontFamily: 'Rajdhani'),
    headlineSmall: base.headlineSmall?.copyWith(fontFamily: 'Rajdhani'),
    titleLarge: base.titleLarge?.copyWith(fontFamily: 'Rajdhani'),
    titleMedium: base.titleMedium?.copyWith(fontFamily: 'Rajdhani'),
    titleSmall: base.titleSmall?.copyWith(fontFamily: 'Rajdhani'),
  );

  logger.info(
    'Active font families - Body: ${textTheme.bodyLarge?.fontFamily}, Display: ${textTheme.displayLarge?.fontFamily}',
    category: LogCategory.app,
  );

  return textTheme;
}
