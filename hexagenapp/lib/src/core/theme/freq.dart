// SPDX-FileCopyrightText: 2025 hexaTune LLC
// SPDX-License-Identifier: MIT

import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff705d00),
      surfaceTint: Color(0xff705d00),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffffd600),
      onPrimaryContainer: Color(0xff705d00),
      secondary: Color(0xff006684),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff00c8ff),
      onSecondaryContainer: Color(0xff005068),
      tertiary: Color(0xff70008b),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff8e24aa),
      onTertiaryContainer: Color(0xfff7bcff),
      error: Color(0xffba002c),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffe9003a),
      onErrorContainer: Color(0xfffffbff),
      surface: Color(0xfffdf8f8),
      onSurface: Color(0xff1c1b1b),
      onSurfaceVariant: Color(0xff46464a),
      outline: Color(0xff77777b),
      outlineVariant: Color(0xffc7c6ca),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff313030),
      inversePrimary: Color(0xffe9c400),
      primaryFixed: Color(0xffffe170),
      onPrimaryFixed: Color(0xff221b00),
      primaryFixedDim: Color(0xffe9c400),
      onPrimaryFixedVariant: Color(0xff544600),
      secondaryFixed: Color(0xffbee9ff),
      onSecondaryFixed: Color(0xff001f2a),
      secondaryFixedDim: Color(0xff68d3ff),
      onSecondaryFixedVariant: Color(0xff004d64),
      tertiaryFixed: Color(0xfffdd6ff),
      onTertiaryFixed: Color(0xff340042),
      tertiaryFixedDim: Color(0xfff3aeff),
      onTertiaryFixedVariant: Color(0xff790096),
      surfaceDim: Color(0xffddd9d8),
      surfaceBright: Color(0xfffdf8f8),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff7f3f2),
      surfaceContainer: Color(0xfff1edec),
      surfaceContainerHigh: Color(0xffebe7e6),
      surfaceContainerHighest: Color(0xffe5e2e1),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff413500),
      surfaceTint: Color(0xff705d00),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff816b00),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff003b4e),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff007698),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff5e0076),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff8e24aa),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff730017),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffdb0036),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffdf8f8),
      onSurface: Color(0xff111111),
      onSurfaceVariant: Color(0xff35363a),
      outline: Color(0xff525256),
      outlineVariant: Color(0xff6d6d71),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff313030),
      inversePrimary: Color(0xffe9c400),
      primaryFixed: Color(0xff816b00),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff655300),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff007698),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff005c77),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xffa53ec0),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff891ea6),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc9c6c5),
      surfaceBright: Color(0xfffdf8f8),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff7f3f2),
      surfaceContainer: Color(0xffebe7e6),
      surfaceContainerHigh: Color(0xffe0dcdb),
      surfaceContainerHighest: Color(0xffd4d1d0),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff362b00),
      surfaceTint: Color(0xff705d00),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff574800),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff003040),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff005068),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff4e0062),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff7c0599),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600012),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff970022),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffdf8f8),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff2b2c30),
      outlineVariant: Color(0xff48494d),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff313030),
      inversePrimary: Color(0xffe9c400),
      primaryFixed: Color(0xff574800),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff3d3200),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff005068),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff003749),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff7c0599),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff59006f),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffbbb8b7),
      surfaceBright: Color(0xfffdf8f8),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff4f0ef),
      surfaceContainer: Color(0xffe5e2e1),
      surfaceContainerHigh: Color(0xffd7d4d3),
      surfaceContainerHighest: Color(0xffc9c6c5),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xfffff5dc),
      surfaceTint: Color(0xffe9c400),
      onPrimary: Color(0xff3a3000),
      primaryContainer: Color(0xffffd600),
      onPrimaryContainer: Color(0xff705d00),
      secondary: Color(0xff99deff),
      onSecondary: Color(0xff003546),
      secondaryContainer: Color(0xff00c8ff),
      onSecondaryContainer: Color(0xff005068),
      tertiary: Color(0xfff3aeff),
      onTertiary: Color(0xff55006a),
      tertiaryContainer: Color(0xff8e24aa),
      onTertiaryContainer: Color(0xfff7bcff),
      error: Color(0xffffb3b3),
      onError: Color(0xff680014),
      errorContainer: Color(0xffff525f),
      onErrorContainer: Color(0xff3d0008),
      surface: Color(0xff141313),
      onSurface: Color(0xffe5e2e1),
      onSurfaceVariant: Color(0xffc7c6ca),
      outline: Color(0xff919095),
      outlineVariant: Color(0xff46464a),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe5e2e1),
      inversePrimary: Color(0xff705d00),
      primaryFixed: Color(0xffffe170),
      onPrimaryFixed: Color(0xff221b00),
      primaryFixedDim: Color(0xffe9c400),
      onPrimaryFixedVariant: Color(0xff544600),
      secondaryFixed: Color(0xffbee9ff),
      onSecondaryFixed: Color(0xff001f2a),
      secondaryFixedDim: Color(0xff68d3ff),
      onSecondaryFixedVariant: Color(0xff004d64),
      tertiaryFixed: Color(0xfffdd6ff),
      onTertiaryFixed: Color(0xff340042),
      tertiaryFixedDim: Color(0xfff3aeff),
      onTertiaryFixedVariant: Color(0xff790096),
      surfaceDim: Color(0xff141313),
      surfaceBright: Color(0xff3a3939),
      surfaceContainerLowest: Color(0xff0e0e0e),
      surfaceContainerLow: Color(0xff1c1b1b),
      surfaceContainer: Color(0xff201f1f),
      surfaceContainerHigh: Color(0xff2b2a2a),
      surfaceContainerHighest: Color(0xff353434),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xfffff5dc),
      surfaceTint: Color(0xffe9c400),
      onPrimary: Color(0xff3a3000),
      primaryContainer: Color(0xffffd600),
      onPrimaryContainer: Color(0xff4f4100),
      secondary: Color(0xffaee4ff),
      onSecondary: Color(0xff002938),
      secondaryContainer: Color(0xff00c8ff),
      onSecondaryContainer: Color(0xff003141),
      tertiary: Color(0xfffbceff),
      onTertiary: Color(0xff440056),
      tertiaryContainer: Color(0xffce64e8),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd1d1),
      onError: Color(0xff54000e),
      errorContainer: Color(0xffff525f),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff141313),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffdddce0),
      outline: Color(0xffb2b1b6),
      outlineVariant: Color(0xff909094),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe5e2e1),
      inversePrimary: Color(0xff564700),
      primaryFixed: Color(0xffffe170),
      onPrimaryFixed: Color(0xff161100),
      primaryFixedDim: Color(0xffe9c400),
      onPrimaryFixedVariant: Color(0xff413500),
      secondaryFixed: Color(0xffbee9ff),
      onSecondaryFixed: Color(0xff00131c),
      secondaryFixedDim: Color(0xff68d3ff),
      onSecondaryFixedVariant: Color(0xff003b4e),
      tertiaryFixed: Color(0xfffdd6ff),
      onTertiaryFixed: Color(0xff23002e),
      tertiaryFixedDim: Color(0xfff3aeff),
      onTertiaryFixedVariant: Color(0xff5e0076),
      surfaceDim: Color(0xff141313),
      surfaceBright: Color(0xff454444),
      surfaceContainerLowest: Color(0xff080707),
      surfaceContainerLow: Color(0xff1e1d1d),
      surfaceContainer: Color(0xff282827),
      surfaceContainerHigh: Color(0xff333232),
      surfaceContainerHighest: Color(0xff3e3d3d),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xfffff5dc),
      surfaceTint: Color(0xffe9c400),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffffd600),
      onPrimaryContainer: Color(0xff2b2300),
      secondary: Color(0xffdef3ff),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xff57d0ff),
      onSecondaryContainer: Color(0xff000d14),
      tertiary: Color(0xffffeafd),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xfff2a8ff),
      onTertiaryContainer: Color(0xff1a0023),
      error: Color(0xffffeceb),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffadad),
      onErrorContainer: Color(0xff220003),
      surface: Color(0xff141313),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xfff1eff4),
      outlineVariant: Color(0xffc3c2c6),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe5e2e1),
      inversePrimary: Color(0xff564700),
      primaryFixed: Color(0xffffe170),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffe9c400),
      onPrimaryFixedVariant: Color(0xff161100),
      secondaryFixed: Color(0xffbee9ff),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xff68d3ff),
      onSecondaryFixedVariant: Color(0xff00131c),
      tertiaryFixed: Color(0xfffdd6ff),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xfff3aeff),
      onTertiaryFixedVariant: Color(0xff23002e),
      surfaceDim: Color(0xff141313),
      surfaceBright: Color(0xff51504f),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff201f1f),
      surfaceContainer: Color(0xff313030),
      surfaceContainerHigh: Color(0xff3c3b3b),
      surfaceContainerHighest: Color(0xff484646),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    textTheme: textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
    scaffoldBackgroundColor: colorScheme.surface,
    canvasColor: colorScheme.surface,
  );

  List<ExtendedColor> get extendedColors => [];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
