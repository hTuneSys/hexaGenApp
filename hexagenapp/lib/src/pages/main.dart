// SPDX-FileCopyrightText: 2025 hexaTune LLC
// SPDX-License-Identifier: MIT

import 'package:flutter/material.dart';
import 'package:hexagenapp/src/pages/generation.dart';
import 'package:hexagenapp/src/pages/history.dart';
import 'package:hexagenapp/src/pages/howtouse.dart';
import 'package:hexagenapp/src/pages/products.dart';
import 'package:hexagenapp/src/pages/settings.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:hexagenapp/l10n/app_localizations.dart';
import 'package:hexagenapp/src/core/service/device_service.dart';

enum MainPageTab { howTo, history, generation, products, settings }

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  MainPageTab _selectedTab = MainPageTab.howTo;
  int _generationItemCount = 0;
  OverlayEntry? _notificationOverlay;

  late final List<Widget> _pages = <Widget>[
    const HowToUsePage(),
    const HistoryPage(),
    GenerationPage(
      onItemCountChanged: (count) {
        setState(() => _generationItemCount = count);
      },
    ),
    const ProductsPage(),
    const SettingsPage(),
  ];

  void _onFabPressed() {
    final lang = AppLocalizations.of(context)!;

    if (_selectedTab != MainPageTab.generation) {
      setState(() {
        _selectedTab = MainPageTab.generation;
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(lang.generateSignal)));
    }
  }

  void _showNotifications() {
    final deviceService = DeviceServiceProvider.of(context);
    if (_notificationOverlay != null) {
      _notificationOverlay!.remove();
      _notificationOverlay = null;
      deviceService.markNotificationsAsRead();
      return;
    }

    _notificationOverlay = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: () {
          _notificationOverlay?.remove();
          _notificationOverlay = null;
          deviceService.markNotificationsAsRead();
        },
        child: Container(
          color: Colors.transparent,
          child: Stack(
            children: [
              Positioned(
                top: MediaQuery.of(context).padding.top + kToolbarHeight,
                left: 16,
                right: 16,
                child: GestureDetector(
                  onTap: () {}, // Prevent dismissal when tapping the panel
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 300),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Text(
                                  'Notifications',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    _notificationOverlay?.remove();
                                    _notificationOverlay = null;
                                    deviceService.markNotificationsAsRead();
                                  },
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1),
                          Expanded(
                            child: deviceService.notifications.isEmpty
                                ? const Center(child: Text('No notifications'))
                                : ListView.builder(
                                    itemCount:
                                        deviceService.notifications.length,
                                    itemBuilder: (context, index) {
                                      final notification =
                                          deviceService.notifications[index];
                                      return ListTile(
                                        title: Text(notification.message),
                                        subtitle: Text(
                                          '${notification.time.hour}:${notification.time.minute.toString().padLeft(2, '0')}',
                                        ),
                                        trailing: notification.read
                                            ? null
                                            : Container(
                                                width: 8,
                                                height: 8,
                                                decoration: BoxDecoration(
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_notificationOverlay!);
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;
    final deviceService = DeviceServiceProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(lang.appName),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              deviceService.hasUnreadNotifications
                  ? Symbols.notifications_active
                  : Symbols.notifications,
            ),
            tooltip: lang.notifications,
            onPressed: _showNotifications,
          ),
        ],
      ),
      // enum -> int
      body: IndexedStack(index: _selectedTab.index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab.index,
        onDestinationSelected: (int i) {
          if (i == MainPageTab.generation.index) {
            _onFabPressed();
            return;
          }
          setState(() => _selectedTab = MainPageTab.values[i]);
        },
        destinations: <NavigationDestination>[
          NavigationDestination(
            icon: const Icon(Symbols.book),
            selectedIcon: const Icon(Symbols.book_rounded, fill: 1),
            tooltip: lang.howToUse,
            label: '',
          ),
          NavigationDestination(
            icon: const Icon(Symbols.alarm),
            selectedIcon: const Icon(Symbols.alarm_rounded, fill: 1),
            tooltip: lang.history,
            label: '',
          ),
          const NavigationDestination(
            icon: Icon(null, color: Colors.transparent, size: 0),
            selectedIcon: Icon(null, color: Colors.transparent, size: 0),
            label: '',
          ),
          NavigationDestination(
            icon: const Icon(Symbols.store),
            selectedIcon: const Icon(Symbols.store_rounded, fill: 1),
            tooltip: lang.ourProducts,
            label: '',
          ),
          NavigationDestination(
            icon: const Icon(Symbols.settings),
            selectedIcon: const Icon(Symbols.settings_rounded, fill: 1),
            tooltip: lang.settings,
            label: '',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onFabPressed,
        tooltip: lang.generateSignal,
        child: Icon(
          _generationItemCount > 0 ? Symbols.autoplay : Symbols.cadence,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
