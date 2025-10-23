// SPDX-FileCopyrightText: 2025 hexaTune LLC
// SPDX-License-Identifier: MIT

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:hexagenapp/src/core/device/device.dart';
import 'package:hexagenapp/src/core/at/at.dart';
import 'package:hexagenapp/src/core/error/error.dart';
import 'package:hexagenapp/src/core/service/log_service.dart';

/// Global device service - Singleton
/// Manages hexaTune device connection and communication throughout app lifecycle
class DeviceService extends ChangeNotifier {
  static final DeviceService _instance = DeviceService._internal();
  factory DeviceService() => _instance;

  DeviceService._internal();

  final _deviceManager = HexaTuneDeviceManager();

  // Device state
  MidiDevice? _currentDevice;
  String? _deviceVersion;
  AppError? _deviceError;
  DeviceStatus _deviceStatus = DeviceStatus.available;
  bool _waitingForResponse = false;
  bool _isInitialized = false;

  // ID generation and command tracking
  static const int _maxId = 9999;
  static const Duration _commandTimeout = Duration(seconds: 5);
  int _nextId = 1;
  final Map<int, SentCommand> _sentCommands = {};
  final Map<int, Timer> _commandTimers = {};

  // Notifications
  static const int _maxNotifications = 5;
  final List<NotificationItem> _notifications = [];
  bool get hasUnreadNotifications => _notifications.any((n) => !n.read);

  // Getters
  MidiDevice? get currentDevice => _currentDevice;
  String? get deviceVersion => _deviceVersion;
  AppError? get deviceError => _deviceError;
  DeviceStatus get deviceStatus => _deviceStatus;
  bool get waitingForResponse => _waitingForResponse;
  bool get isConnected =>
      _currentDevice != null && _deviceManager.connectedId != null;
  bool get isInitialized => _isInitialized;

  /// Initialize the device service
  Future<void> initialize() async {
    if (_isInitialized) return;

    logger.info('Initializing device service', category: LogCategory.device);

    _deviceManager.initialize(
      onDeviceChanged: _onDeviceChanged,
      onResponse: _onResponse,
    );

    await _loadDevices();
    _isInitialized = true;

    logger.info('Device service initialized', category: LogCategory.device);
  }

  /// Generate next sequential ID (1-9999, wraps around)
  int _generateId() {
    final id = _nextId;
    _nextId = _nextId % _maxId + 1;
    return id;
  }

  /// Track sent command
  void _trackCommand(int id, String command) {
    _sentCommands[id] = SentCommand(
      id,
      command,
      DateTime.now(),
      CommandStatus.pending,
    );
    _commandTimers[id] = Timer(_commandTimeout, () {
      _updateCommandStatus(id, CommandStatus.timeout);
      _addNotification('Command timeout: $command');
      _commandTimers.remove(id);
    });
    logger.debug(
      'Tracked command: $command (ID: $id)',
      category: LogCategory.device,
    );
  }

  /// Update command status based on response
  void _updateCommandStatus(int id, CommandStatus status, {String? errorCode}) {
    final command = _sentCommands[id];
    if (command != null) {
      command.status = status;
      command.errorCode = errorCode;
      _commandTimers[id]?.cancel();
      _commandTimers.remove(id);
      logger.debug(
        'Updated command status: ${command.command} (ID: $id) -> $status',
        category: LogCategory.device,
      );
    }
  }

  /// Dispose the device service
  void disposeService() {
    logger.info('Disposing device service', category: LogCategory.device);
    _deviceManager.dispose();
    _isInitialized = false;
  }

  /// Load and connect to hexaTune device
  Future<void> _loadDevices() async {
    logger.debug('Scanning for hexaTune devices', category: LogCategory.device);

    final hexaDevice = await _deviceManager.findHexaTuneDevice();

    _currentDevice = hexaDevice;
    notifyListeners();

    if (hexaDevice != null) {
      logger.info(
        'hexaTune device found: ${hexaDevice.name}',
        category: LogCategory.device,
      );
      _addNotification('Device connected: ${hexaDevice.name}');
      unawaited(_connectDevice(hexaDevice));
    } else {
      logger.warning('No hexaTune device found', category: LogCategory.device);
      _deviceVersion = null;
      _deviceError = null;
      _waitingForResponse = false;
      _deviceManager.clearConnection();
      notifyListeners();
    }
  }

  /// Handle device changes (plug/unplug)
  void _onDeviceChanged() {
    logger.info(
      'Device configuration changed (plug/unplug detected)',
      category: LogCategory.device,
    );
    _loadDevices();
  }

  /// Handle device response
  void _onResponse({
    String? version,
    AppError? error,
    DeviceStatus? status,
    int? responseId,
    required bool waiting,
  }) {
    if (version != null) {
      logger.info(
        'Device version received: $version',
        category: LogCategory.device,
      );
    }
    if (error != null) {
      logger.warning(
        'Device error received: ${error.code}',
        category: LogCategory.device,
      );
    }
    if (status != null) {
      logger.debug(
        'Device status received: $status',
        category: LogCategory.device,
      );
    }

    _deviceVersion = version;
    _deviceError = error;
    if (status != null) {
      if (_deviceStatus != status) {
        _addNotification('Device status changed to ${status.name}');
      }
      _deviceStatus = status;
    }

    // Update command status if responseId provided
    if (responseId != null) {
      if (error != null) {
        _updateCommandStatus(
          responseId,
          CommandStatus.error,
          errorCode: error.code,
        );
        _addNotification('Command failed: ${error.code}');
      } else if (version != null || status != null) {
        _updateCommandStatus(responseId, CommandStatus.success);
      }
    }

    // Add notification for version received
    if (version != null) {
      _addNotification('Device version: $version');
    }

    _waitingForResponse = waiting;
    notifyListeners();
  }

  /// Connect to device
  Future<void> _connectDevice(MidiDevice device) async {
    logger.info(
      'Connecting to device: ${device.name} (ID: ${device.id})',
      category: LogCategory.device,
    );

    try {
      await _deviceManager.connectAndQueryVersion(device);
      logger.info('Device connection successful', category: LogCategory.device);
    } catch (e, stack) {
      logger.error(
        'Device connection failed',
        category: LogCategory.device,
        error: e,
        stackTrace: stack,
      );
    }
  }

  /// Manually trigger device refresh
  Future<void> refresh() async {
    logger.debug(
      'Manual device refresh triggered',
      category: LogCategory.device,
    );
    await _loadDevices();
  }

  /// Send AT command generically
  Future<void> sendATCommand(ATCommand command) async {
    if (_deviceManager.connectedId == null) {
      logger.warning(
        'Cannot send ${command.type.name} command: No device connected',
        category: LogCategory.device,
      );
      return;
    }
    final compiled = command.compile();
    _trackCommand(command.id, compiled);
    logger.info(
      'Sending ${command.type.name} command: $compiled',
      category: LogCategory.midi,
    );
    _deviceManager.sendData(command.buildSysEx(), _deviceManager.connectedId!);
  }

  /// Send AT+FREQ command
  Future<void> sendFreqCommand(int freq, int timeMs) async {
    final id = _generateId();
    final command = ATCommand.freq(id, freq, timeMs);
    await sendATCommand(command);
  }

  /// Send AT+SETRGB command
  Future<void> sendSetRgbCommand(int r, int g, int b) async {
    final id = _generateId();
    final command = ATCommand.setRgb(id, r, g, b);
    await sendATCommand(command);
  }

  /// Send AT+RESET command
  Future<void> sendResetCommand() async {
    final id = _generateId();
    final command = ATCommand.reset(id);
    await sendATCommand(command);
  }

  /// Send AT+FWUPDATE command
  Future<void> sendFwUpdateCommand() async {
    final id = _generateId();
    final command = ATCommand.fwUpdate(id);
    await sendATCommand(command);
  }

  /// Send raw data to device
  void sendData(Uint8List bytes, String deviceId) {
    _deviceManager.sendData(bytes, deviceId);
  }

  /// Add notification
  void _addNotification(String message) {
    _notifications.insert(0, NotificationItem(message, DateTime.now()));
    if (_notifications.length > _maxNotifications) {
      _notifications.removeLast();
    }
    notifyListeners();
  }

  /// Mark all notifications as read
  void markNotificationsAsRead() {
    for (final n in _notifications) {
      n.read = true;
    }
    notifyListeners();
  }

  /// Get notifications
  List<NotificationItem> get notifications => _notifications;
}

/// Provider widget for DeviceService
class DeviceServiceProvider extends InheritedNotifier<DeviceService> {
  const DeviceServiceProvider({
    super.key,
    required DeviceService deviceService,
    required super.child,
  }) : super(notifier: deviceService);

  static DeviceService of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<DeviceServiceProvider>();
    assert(provider != null, 'No DeviceServiceProvider found in context');
    return provider!.notifier!;
  }

  static DeviceService? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<DeviceServiceProvider>()
        ?.notifier;
  }
}
