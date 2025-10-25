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
import 'package:hexagenapp/src/core/service/storage_service.dart';
import 'package:hexagenapp/src/core/service/notification_service.dart';
import 'package:hexagenapp/src/core/at/at.dart';
import 'package:hexagenapp/src/core/service/log_service.dart';

enum MainPageTab { howTo, history, generation, products, settings }

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  MainPageTab _selectedTab = MainPageTab.howTo;
  int _generationItemCount = 0;
  OverlayEntry? _notificationOverlay;
  bool _isSending = false;
  AppLifecycleState _lifecycleState = AppLifecycleState.resumed;

  final GlobalKey _generationKey = GlobalKey();

  void _handleRegenerate(List<Map<String, dynamic>> items, int repeatCount) {
    final state = _generationKey.currentState as dynamic;
    state?.loadSequence(items, repeatCount);
    setState(() => _selectedTab = MainPageTab.generation);
  }

  late final List<Widget> _pages = <Widget>[
    const HowToUsePage(),
    HistoryPage(onRegenerate: _handleRegenerate),
    GenerationPage(
      key: _generationKey,
      onItemCountChanged: (count) {
        setState(() => _generationItemCount = count);
      },
      onItemStatusChanged: (index, status) {},
    ),
    const ProductsPage(),
    const SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _listenToBackgroundService();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycleState = state;
    if (state == AppLifecycleState.detached && _isSending) {
      _stopOperation();
    }
  }

  void _listenToBackgroundService() {}

  void _onFabPressed() {
    if (_selectedTab != MainPageTab.generation) {
      setState(() {
        _selectedTab = MainPageTab.generation;
      });
    } else if (_generationItemCount > 0 && !_isSending) {
      _startOperation();
    } else if (_isSending) {
      _stopOperation();
    }
  }

  void _startOperation() async {
    final state = _generationKey.currentState as dynamic;
    final sequence = state?.getSequence() ?? [];
    final repeatCount = state?.getRepeatCount() ?? 1;
    final operationId = DateTime.now().millisecondsSinceEpoch.toString();
    final lang = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final errorColor = Theme.of(context).colorScheme.error;

    logger.print(
      'MainPage: Starting operation with ${sequence.length} items, repeat $repeatCount',
    );

    state?.resetAllItemStatuses();
    setState(() => _isSending = true);

    final deviceService = DeviceServiceProvider.of(context);
    bool success = true;
    bool cancelled = false;

    try {
      for (int r = 0; r < repeatCount && !cancelled; r++) {
        if (!_isSending) {
          cancelled = true;
          break;
        }
        logger.print('MainPage: Starting repeat $r');
        for (int i = 0; i < sequence.length; i++) {
          if (!_isSending) {
            cancelled = true;
            break;
          }
          final item = sequence[i];
          final freqHz = item['freqHz'] as int;
          final timeMs = ((item['seconds'] as double) * 1000).round();

          state?.updateItemStatus(i, ItemStatus.processing);
          logger.print('MainPage: Sending FREQ $freqHz Hz for ${timeMs}ms');

          try {
            final status = await deviceService.sendFreqCommandAndWait(
              freqHz,
              timeMs,
            );
            logger.print('MainPage: Command status: $status');
            if (status != CommandStatus.success) {
              state?.updateItemStatus(i, ItemStatus.error);
              success = false;
              break;
            }
            state?.updateItemStatus(i, ItemStatus.completed);
          } catch (e) {
            logger.print('MainPage: Exception in sendFreqCommandAndWait: $e');
            state?.updateItemStatus(i, ItemStatus.error);
            success = false;
            break;
          }
        }
        if (!success) break;

        if (r < repeatCount - 1) {
          state?.resetAllItemStatuses();
        }
      }
    } catch (e) {
      logger.print('MainPage: Exception in loop: $e');
      success = false;
    }

    if (success && !cancelled) {
      logger.print('MainPage: Sending complete');
      _saveOperation(operationId);
      deviceService.addNotification(lang.operationCompletedSuccessfully);

      if (_lifecycleState != AppLifecycleState.resumed) {
        await NotificationService().showNotification(
          title: 'hexaGen',
          body: lang.operationCompletedSuccessfully,
        );
      }
    } else if (cancelled) {
      logger.print('MainPage: Cancelled, sending reset');
      state?.resetAllItemStatuses();
      deviceService.addNotification(lang.operationStoppedByUser);
      try {
        await deviceService.sendResetCommand();
        logger.print('MainPage: Reset sent');
      } catch (e) {
        logger.print('MainPage: Exception sending reset: $e');
      }
    } else {
      state?.resetAllItemStatuses();
      final errorMessage = lang.operationFailedCheckDevice;
      deviceService.addNotification(lang.operationFailedWithErrors);

      if (_lifecycleState != AppLifecycleState.resumed) {
        await NotificationService().showNotification(
          title: 'hexaGen',
          body: lang.operationFailedWithErrors,
          isError: true,
        );
      }

      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: errorColor),
        );
      }
    }

    setState(() => _isSending = false);
  }

  void _stopOperation() async {
    logger.print('MainPage: Stopping operation');
    setState(() => _isSending = false);

    final state = _generationKey.currentState as dynamic;
    state?.resetAllItemStatuses();

    final deviceService = DeviceServiceProvider.of(context);
    final lang = AppLocalizations.of(context)!;
    final stoppedMessage = lang.operationStopped;
    final messenger = ScaffoldMessenger.of(context);
    deviceService.addNotification(lang.operationStoppedByUser);

    try {
      await deviceService.sendResetCommand();
      logger.print('MainPage: Reset command sent immediately');
    } catch (e) {
      logger.print('MainPage: Exception sending reset: $e');
    }

    if (context.mounted) {
      messenger.showSnackBar(SnackBar(content: Text(stoppedMessage)));
    }
  }

  void _saveOperation(String operationId) {
    final state = _generationKey.currentState as dynamic;
    final sequence = state?.getSequence() ?? [];
    final repeatCount = state?.getRepeatCount() ?? 1;

    final operation = {
      'id': operationId,
      'timestamp': DateTime.now().toIso8601String(),
      'repeatCount': repeatCount,
      'items': sequence,
    };

    final storageService = StorageServiceProvider.of(context);
    storageService.saveOperation(operation);

    final lang = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(lang.operationCompletedAndSaved)));
  }

  void _showNotifications() {
    final deviceService = DeviceServiceProvider.of(context);
    final lang = AppLocalizations.of(context)!;
    if (_notificationOverlay != null) {
      _notificationOverlay!.remove();
      _notificationOverlay = null;
      deviceService.markNotificationsAsRead();
      return;
    }

    _notificationOverlay = OverlayEntry(
      builder: (overlayContext) => GestureDetector(
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
                top: MediaQuery.of(overlayContext).padding.top + kToolbarHeight,
                left: 16,
                right: 16,
                child: GestureDetector(
                  onTap: () {},
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 300),
                      decoration: BoxDecoration(
                        color: Theme.of(overlayContext).colorScheme.surface,
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
                                  lang.notificationsTitle,
                                  style: Theme.of(
                                    overlayContext,
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
                                ? Center(child: Text(lang.noNotifications))
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.inversePrimary,
        title: Text(lang.appName),
        actions: <Widget>[
          Icon(
            Symbols.circle,
            color: _isSending ? colorScheme.tertiary : colorScheme.error,
          ),
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
          _isSending
              ? Symbols.stop
              : (_generationItemCount > 0 ? Symbols.autoplay : Symbols.cadence),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
