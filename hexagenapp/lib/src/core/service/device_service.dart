// SPDX-FileCopyrightText: 2025 hexaTune LLC
// SPDX-License-Identifier: MIT

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:hexagenapp/src/core/device/device.dart';
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
  bool _waitingForResponse = false;
  bool _isInitialized = false;

  // Getters
  MidiDevice? get currentDevice => _currentDevice;
  String? get deviceVersion => _deviceVersion;
  AppError? get deviceError => _deviceError;
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
  void _onResponse({String? version, AppError? error, required bool waiting}) {
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

    _deviceVersion = version;
    _deviceError = error;
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

  /// Send custom AT command (for future use)
  Future<void> sendCommand(String command) async {
    if (_deviceManager.connectedId == null) {
      logger.warning(
        'Cannot send command: No device connected',
        category: LogCategory.device,
      );
      return;
    }
    logger.debug(
      'Sending custom command: $command',
      category: LogCategory.midi,
    );
    // TODO: Implement custom command sending
  }
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
