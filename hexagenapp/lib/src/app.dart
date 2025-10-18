// SPDX-FileCopyrightText: 2025 hexaTune LLC
// SPDX-License-Identifier: MIT

import 'package:flutter/material.dart';
import 'package:hexagenapp/src/core/theme/freq.dart';
import 'package:hexagenapp/src/core/utils/theme.dart';
import 'package:hexagenapp/src/pages/main.dart';
import 'package:hexagenapp/l10n/app_localizations.dart';
import 'package:hexagenapp/src/core/service/device_service.dart';
import 'package:hexagenapp/src/core/service/storage_service.dart';
import 'package:hexagenapp/src/core/service/log_service.dart';

class HexaGenApp extends StatefulWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  const HexaGenApp({super.key});

  @override
  State<HexaGenApp> createState() => _HexaGenAppState();
}

class _HexaGenAppState extends State<HexaGenApp> {
  final _deviceService = DeviceService();
  final _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    logger.info('App starting', category: LogCategory.app);
    // Initialize services when app starts
    _storageService.initialize();
    _deviceService.initialize();
  }

  @override
  void dispose() {
    logger.info('App disposing', category: LogCategory.app);
    _deviceService.disposeService();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = createTextTheme(context, "Inter", "Rajdhani");
    MaterialTheme theme = MaterialTheme(textTheme);

    return StorageServiceProvider(
      notifier: _storageService,
      child: DeviceServiceProvider(
        deviceService: _deviceService,
        child: AnimatedBuilder(
          animation: _storageService,
          builder: (context, child) {
            return MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              title: 'hexaGen',
              debugShowCheckedModeBanner: false,
              themeMode: _storageService.themeModeValue,
              theme: theme.light(),
              darkTheme: theme.dark(),
              navigatorKey: HexaGenApp.navigatorKey,
              scaffoldMessengerKey: HexaGenApp.scaffoldMessengerKey,
              home: const MainPage(),
              navigatorObservers: [_LoggingNavigatorObserver()],
            );
          },
        ),
      ),
    );
  }
}

/// Navigator observer for logging page navigation
class _LoggingNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name != null) {
      logger.navigation('Navigated to: ${route.settings.name}');
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute?.settings.name != null) {
      logger.navigation('Returned to: ${previousRoute!.settings.name}');
    }
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute?.settings.name != null) {
      logger.navigation('Replaced with: ${newRoute!.settings.name}');
    }
  }
}
