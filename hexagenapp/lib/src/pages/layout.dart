// SPDX-FileCopyrightText: 2025 hexaTune LLC
// SPDX-License-Identifier: MIT

import 'dart:async';
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
import 'package:hexagenapp/src/core/at/at.dart';
import 'package:hexagenapp/src/core/service/log_service.dart';
import 'package:hexagenapp/src/core/error/error.dart';

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
  int _operationId = 1; // Auto-incrementing operation ID
  Timer? _pollingTimer;

  // Repeat functionality
  int _currentRepeatIteration = 0;
  int _totalRepeats = 1;

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
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached && _isSending) {
      _stopOperation();
    }
  }

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

    // Initialize repeat tracking
    _currentRepeatIteration = 1;
    _totalRepeats = repeatCount;

    logger.print(
      'MainPage: Starting operation ID $_operationId with ${sequence.length} items, total repeats: $_totalRepeats',
    );

    setState(() => _isSending = true);

    // Execute the first iteration
    await _executeIteration(state, sequence);
  }

  Future<void> _executeIteration(
    dynamic state,
    List<Map<String, dynamic>> sequence,
  ) async {
    final lang = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final errorColor = Theme.of(context).colorScheme.error;

    logger.print(
      'MainPage: === Iteration $_currentRepeatIteration/$_totalRepeats ===',
    );

    state?.resetAllItemStatuses();

    final deviceService = DeviceServiceProvider.of(context);
    bool success = true;
    bool cancelled = false;

    try {
      // PHASE 1: PREPARE
      logger.print(
        'MainPage: PHASE 1 - Sending PREPARE for operation $_operationId (iteration $_currentRepeatIteration)',
      );
      final prepareStatus = await deviceService.sendOperationPrepare(
        _operationId,
      );

      if (prepareStatus != CommandStatus.success) {
        logger.print('MainPage: PREPARE failed with status: $prepareStatus');
        success = false;
      } else {
        logger.print('MainPage: PREPARE completed successfully');

        // PHASE 2: FREQ batch
        logger.print('MainPage: PHASE 2 - Sending FREQ commands');
        for (int i = 0; i < sequence.length && success; i++) {
          if (!_isSending) {
            cancelled = true;
            break;
          }

          final item = sequence[i];
          final freqHz = item['freqHz'] as int;
          final timeMs = ((item['seconds'] as double) * 1000).round();
          final stepId = i; // Use list index as stepId

          state?.updateItemStatus(i, ItemStatus.processing);
          logger.print(
            'MainPage: Sending FREQ stepId=$stepId freq=$freqHz Hz time=${timeMs}ms',
          );

          try {
            final status = await deviceService.sendFreqCommandForOperation(
              stepId,
              freqHz,
              timeMs,
            );

            if (status != CommandStatus.success) {
              logger.print(
                'MainPage: FREQ stepId=$stepId failed with status: $status',
              );
              state?.updateItemStatus(i, ItemStatus.error);
              success = false;
              break;
            }

            logger.print('MainPage: FREQ stepId=$stepId completed');
            state?.updateItemStatus(i, ItemStatus.completed);
          } catch (e) {
            logger.print('MainPage: Exception sending FREQ stepId=$stepId: $e');
            state?.updateItemStatus(i, ItemStatus.error);
            success = false;
            break;
          }
        }

        // PHASE 3: GENERATE
        if (success && !cancelled) {
          logger.print(
            'MainPage: PHASE 3 - Sending GENERATE for operation $_operationId (iteration $_currentRepeatIteration)',
          );
          state?.resetAllItemStatuses();

          await deviceService.sendOperationGenerate(_operationId);
          logger.print('MainPage: GENERATE sent, starting polling');
          _startPolling(deviceService, state);
        }
      }
    } catch (e) {
      logger.print('MainPage: Exception in operation: $e');
      success = false;
    }

    // Handle immediate failures (before polling starts)
    if (!success || cancelled) {
      _pollingTimer?.cancel();
      deviceService.resetOperationState();

      if (cancelled) {
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

        if (context.mounted) {
          messenger.showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: errorColor),
          );
        }
      }

      // Reset repeat tracking and stop
      _currentRepeatIteration = 0;
      _totalRepeats = 1;
      setState(() => _isSending = false);
    }
    // If successful and polling started, completion will be handled by _handleOperationCompletion
  }

  void _startPolling(DeviceService deviceService, dynamic state) {
    logger.print('MainPage: Starting polling timer (5 seconds interval)');

    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (!_isSending) {
        logger.print('MainPage: Polling stopped - operation cancelled');
        timer.cancel();
        return;
      }

      logger.print('MainPage: Polling operation status...');
      try {
        await deviceService.queryOperationStatus();

        // Check for operation errors first
        final error = deviceService.currentOperationError;
        if (error != null) {
          logger.print('MainPage: Operation ERROR detected: ${error.code}');
          timer.cancel();
          _handleOperationCompletion(
            false,
            'Operation error: ${error.code}',
            state,
          );
          return;
        }

        // Check if operation completed or failed
        final status = deviceService.currentOperationStatus;
        final stepId = deviceService.currentGeneratingStepId;

        logger.print('MainPage: Current status: $status, stepId: $stepId');

        if (status == 'COMPLETED') {
          logger.print('MainPage: Operation COMPLETED detected');
          timer.cancel();
          _handleOperationCompletion(true, null, state);
        } else if (status == 'ERROR') {
          logger.print('MainPage: Operation ERROR status detected');
          timer.cancel();
          _handleOperationCompletion(false, 'Operation failed', state);
        } else if (status == 'GENERATING' && stepId != null) {
          // Update UI with current step
          // Previous steps (0 to stepId-1) should be marked as completed
          // Current step (stepId) should be marked as processing
          logger.print('MainPage: GENERATING at stepId=$stepId');
          _updateGeneratingProgress(state, stepId);
        }
      } catch (e) {
        logger.print('MainPage: Exception during polling: $e');
        timer.cancel();
        _handleOperationCompletion(false, 'Polling error: $e', state);
      }
    });

    // Errors are also handled via device callback in _onResponse
  }

  void _updateGeneratingProgress(dynamic state, int currentStepId) {
    if (state == null) return;

    final sequence = state.getSequence() ?? [];

    // Mark all previous steps as completed
    for (int i = 0; i < currentStepId && i < sequence.length; i++) {
      logger.print(
        'MainPage: Marking stepId=$i as completed (before current step)',
      );
      state.updateItemStatus(i, ItemStatus.completed);
    }

    // Mark current step as processing
    if (currentStepId < sequence.length) {
      logger.print(
        'MainPage: Marking stepId=$currentStepId as processing (current step)',
      );
      state.updateItemStatus(currentStepId, ItemStatus.processing);
    }
  }

  void _handleOperationCompletion(
    bool success,
    String? errorMessage,
    dynamic state,
  ) async {
    logger.print(
      'MainPage: Handling operation completion - success: $success (iteration $_currentRepeatIteration/$_totalRepeats)',
    );

    _pollingTimer?.cancel();
    final deviceService = DeviceServiceProvider.of(context);
    deviceService.resetOperationState();

    final lang = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final errorColor = Theme.of(context).colorScheme.error;

    if (success) {
      logger.print(
        'MainPage: Iteration $_currentRepeatIteration/$_totalRepeats completed successfully',
      );

      // Mark all items as completed
      final sequence = state?.getSequence() ?? [];
      for (int i = 0; i < sequence.length; i++) {
        state?.updateItemStatus(i, ItemStatus.completed);
      }

      // Check if we need to do more iterations
      if (_currentRepeatIteration < _totalRepeats) {
        // Show notification for completed iteration
        final iterationMessage =
            'Iteration $_currentRepeatIteration/$_totalRepeats completed';
        deviceService.addNotification(iterationMessage);
        logger.print('MainPage: Starting next iteration...');

        // Increment iteration counter
        _currentRepeatIteration++;

        // Wait a brief moment before starting next iteration
        await Future.delayed(const Duration(milliseconds: 500));

        // Execute next iteration with same operation ID
        if (_isSending) {
          await _executeIteration(state, sequence);
        }
      } else {
        // All iterations completed - save and finish
        logger.print(
          'MainPage: All $_totalRepeats iterations completed successfully',
        );

        final operationIdStr = _operationId.toString();
        _saveOperation(operationIdStr);
        deviceService.addNotification(
          'Operation completed: $_totalRepeats iteration${_totalRepeats > 1 ? 's' : ''}',
        );

        // Reset repeat tracking
        _currentRepeatIteration = 0;
        _totalRepeats = 1;

        // Increment operation ID for next operation (1-9999, wrap around)
        _operationId = (_operationId % 9999) + 1;
        logger.print('MainPage: Next operation ID will be $_operationId');

        setState(() => _isSending = false);
      }
    } else {
      // Operation failed
      logger.print(
        'MainPage: Iteration $_currentRepeatIteration/$_totalRepeats failed: $errorMessage',
      );
      state?.resetAllItemStatuses();
      final displayMessage = errorMessage ?? lang.operationFailedCheckDevice;
      deviceService.addNotification(
        'Operation failed at iteration $_currentRepeatIteration/$_totalRepeats',
      );

      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(displayMessage), backgroundColor: errorColor),
        );
      }

      // Reset repeat tracking
      _currentRepeatIteration = 0;
      _totalRepeats = 1;

      setState(() => _isSending = false);
    }
  }

  void _stopOperation() async {
    logger.print(
      'MainPage: Stopping operation (was at iteration $_currentRepeatIteration/$_totalRepeats)',
    );

    _pollingTimer?.cancel();
    setState(() => _isSending = false);

    final state = _generationKey.currentState as dynamic;
    state?.resetAllItemStatuses();

    final deviceService = DeviceServiceProvider.of(context);
    deviceService.resetOperationState();

    // Reset repeat tracking
    _currentRepeatIteration = 0;
    _totalRepeats = 1;

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
