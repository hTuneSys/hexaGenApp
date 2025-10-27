// SPDX-FileCopyrightText: 2025 hexaTune LLC
// SPDX-License-Identifier: MIT

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:hexagenapp/src/core/error/error.dart';
import 'package:hexagenapp/src/core/at/at.dart';
import 'package:hexagenapp/src/core/sysex/sysex.dart';
import 'package:hexagenapp/src/core/service/log_service.dart';

/// Device response callback
typedef DeviceResponseCallback =
    void Function({
      String? version,
      AppError? error,
      DeviceStatus? status,
      int? responseId,
      String? operationStatus,
      int? operationStepId,
      required bool waiting,
    });

/// HexaTune device manager
class HexaTuneDeviceManager {
  final MidiCommand _midi = MidiCommand();
  final RegExp _hexaPattern = RegExp(r'hexa', caseSensitive: false);

  StreamSubscription<dynamic>? _setupSub;
  StreamSubscription<dynamic>? _dataSub;

  bool _connecting = false;
  String? _connectedId;
  bool _waitingForResponse = false;
  Timer? _responseTimeout;
  final List<int> _sysexBuffer = []; // SysEx message buffer

  DeviceResponseCallback? _responseCallback;

  /// Initialize device manager with callbacks
  void initialize({
    required void Function() onDeviceChanged,
    required DeviceResponseCallback onResponse,
  }) {
    _responseCallback = onResponse;

    _setupSub = _midi.onMidiSetupChanged?.listen((_) {
      onDeviceChanged();
    });

    _dataSub = _midi.onMidiDataReceived?.listen((packet) {
      _handleATResponse(packet.data);
    });
  }

  /// Dispose resources
  void dispose() {
    _setupSub?.cancel();
    _dataSub?.cancel();
    _responseTimeout?.cancel();
  }

  /// Get all MIDI devices
  Future<List<MidiDevice>> getDevices() async {
    return await _midi.devices ?? <MidiDevice>[];
  }

  /// Find hexaTune device
  Future<MidiDevice?> findHexaTuneDevice() async {
    final all = await getDevices();
    for (final d in all) {
      if (matchesHexaTune(d)) {
        return d;
      }
    }
    return null;
  }

  /// Check if device name matches hexaTune pattern
  bool matchesHexaTune(MidiDevice d) {
    final name = d.name;
    // ignore: unnecessary_null_comparison, dead_code
    if (name == null) return false;
    return name.toLowerCase().contains(_hexaPattern.pattern);
  }

  /// Get connected device ID
  Future<String?> getConnectedDeviceId() async {
    final all = await getDevices();
    final connected = all.where((d) => d.connected == true).toList();
    return connected.isNotEmpty ? connected.first.id : null;
  }

  /// Check if specific device is connected
  Future<bool> isDeviceConnected(String id) async {
    final list = await getDevices();
    return list.any((x) => x.id == id && x.connected == true);
  }

  /// Connect to device and query version
  Future<void> connectAndQueryVersion(MidiDevice device) async {
    final deviceId = device.id;
    // ignore: unnecessary_null_comparison, dead_code
    if (deviceId == null) return;
    if (_connecting) return;

    if (await isDeviceConnected(deviceId)) {
      _connectedId = deviceId;
      sendATVersion(deviceId);
      return;
    }

    _connecting = true;
    _notifyResponse(version: null, error: null, waiting: true);

    try {
      // Disconnect other devices
      final current = await getDevices();
      for (final dev in current) {
        if (dev.connected == true && dev.id != device.id) {
          try {
            _midi.disconnectDevice(dev);
          } catch (_) {}
        }
      }

      await Future.delayed(const Duration(milliseconds: 200));

      _midi.connectToDevice(device);

      // Wait for connection
      for (int i = 0; i < 20; i++) {
        await Future.delayed(const Duration(milliseconds: 150));
        if (await isDeviceConnected(deviceId)) {
          _connectedId = deviceId;
          break;
        }
      }

      if (_connectedId == deviceId) {
        // Extra delay - to allow the device's firmware to be ready
        // Firmware starts multiple tasks, it may take ~1-2 seconds to be ready
        await Future.delayed(const Duration(milliseconds: 1500));
        sendATVersion(deviceId);
      }
    } on PlatformException {
      _notifyResponse(version: null, error: null, waiting: false);
      rethrow;
    } finally {
      _connecting = false;
    }
  }

  /// Send AT+VERSION? command
  void sendATVersion(String deviceId) {
    final command = ATCommand.version();
    final bytes = command.buildSysEx();
    _waitingForResponse = true;
    _sysexBuffer.clear();
    _notifyResponse(
      version: null,
      error: null,
      status: null,
      responseId: null,
      waiting: true,
    );

    logger.midi('Sending AT+VERSION? command (${bytes.length} bytes)');

    _midi.sendData(bytes, deviceId: deviceId);

    // Track the command (ID 0 for version query)
    // Note: Firmware uses ID 0 for version, so we track with 0
    // For future commands, use generated IDs
    // _trackCommand(0, 'AT+VERSION?'); // If DeviceService had access

    // Set timeout - if no response in 10 seconds
    _responseTimeout?.cancel();
    _responseTimeout = Timer(const Duration(seconds: 10), () {
      if (_waitingForResponse) {
        logger.warning(
          'AT+VERSION? response timeout',
          category: LogCategory.midi,
        );
        _waitingForResponse = false;
        _sysexBuffer.clear();
        _notifyResponse(
          version: 'No response',
          error: null,
          status: null,
          responseId: null,
          waiting: false,
        );
      }
    });
  }

  /// Send raw data
  void sendData(Uint8List bytes, String deviceId) {
    _midi.sendData(bytes, deviceId: deviceId);
  }

  /// Handle AT command response
  void _handleATResponse(Uint8List bytes) {
    logger.print(
      'Received MIDI data: ${bytes.length} bytes (Hex: ${bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')})',
    );
    logger.midi('Received MIDI data: ${bytes.length} bytes');

    // Add to buffer
    _sysexBuffer.addAll(bytes);

    // Check if F7 (SysEx end) marker received
    final hasEndMarker = _sysexBuffer.contains(0xF7);

    if (!hasEndMarker) {
      logger.debug(
        'Waiting for more data (buffer: ${_sysexBuffer.length} bytes)',
        category: LogCategory.midi,
      );
      return; // Wait for more data
    }

    // Cancel timeout
    _responseTimeout?.cancel();

    try {
      final bufferedData = Uint8List.fromList(_sysexBuffer);
      final message = SysEx.extractSysexPayload(bufferedData);

      // Clear the buffer
      _sysexBuffer.clear();

      if (message == null) {
        logger.warning(
          'Failed to extract SysEx payload',
          category: LogCategory.midi,
        );
        _waitingForResponse = false;
        return;
      }

      logger.midi('Decoded AT response: "$message"');
      _waitingForResponse = false;

      final response = parseATResponse(message);

      if (response == null) {
        logger.warning(
          'Unknown AT response format: "$message"',
          category: LogCategory.midi,
        );
        return;
      }

      switch (response.type) {
        case ATResponseType.error:
          logger.warning(
            'AT Error: ${response.errorCode} (id: ${response.id})',
            category: LogCategory.midi,
          );
          final error = AppErrorExtension.fromCode(response.errorCode);
          final id = int.tryParse(response.id) ?? 0;
          _notifyResponse(
            version: null,
            error: error,
            status: null,
            responseId: id,
            waiting: false,
          );
          break;

        case ATResponseType.version:
          logger.info(
            'AT Version: ${response.version} (id: ${response.id})',
            category: LogCategory.midi,
          );
          final id = int.tryParse(response.id) ?? 0;
          _notifyResponse(
            version: response.version,
            error: null,
            status: null,
            responseId: id,
            waiting: false,
          );
          break;

        case ATResponseType.operation:
          logger.info(
            'AT Operation: status=${response.operationStatus}, stepId=${response.operationStepId} (id: ${response.id})',
            category: LogCategory.midi,
          );
          final id = int.tryParse(response.id) ?? 0;
          _notifyResponse(
            version: null,
            error: null,
            status: null,
            responseId: id,
            operationStatus: response.operationStatus,
            operationStepId: response.operationStepId,
            waiting: false,
          );
          break;

        case ATResponseType.freq:
          logger.info(
            'AT Freq: completed=${response.freqCompleted} (id: ${response.id})',
            category: LogCategory.midi,
          );
          final id = int.tryParse(response.id) ?? 0;
          _notifyResponse(
            version: null,
            error: null,
            status: null,
            responseId: id,
            waiting: false,
          );
          break;

        case ATResponseType.done:
          logger.info(
            'AT Done (id: ${response.id})',
            category: LogCategory.midi,
          );
          final id = int.tryParse(response.id) ?? 0;
          _notifyResponse(
            version: null,
            error: null,
            status: null,
            responseId: id,
            waiting: false,
          );
          break;

        case ATResponseType.status:
          logger.debug(
            'AT Status: ${response.status} (id: ${response.id})',
            category: LogCategory.midi,
          );
          final id = int.tryParse(response.id) ?? 0;
          _notifyResponse(
            version: null,
            error: null,
            status: response.status,
            responseId: id,
            waiting: false,
          );
          break;
      }
    } catch (e, stack) {
      logger.error(
        'Error parsing AT response',
        category: LogCategory.midi,
        error: e,
        stackTrace: stack,
      );
      _sysexBuffer.clear();
      _waitingForResponse = false;
    }
  }

  /// Notify response callback
  void _notifyResponse({
    String? version,
    AppError? error,
    DeviceStatus? status,
    int? responseId,
    String? operationStatus,
    int? operationStepId,
    required bool waiting,
  }) {
    _responseCallback?.call(
      version: version,
      error: error,
      status: status,
      responseId: responseId,
      operationStatus: operationStatus,
      operationStepId: operationStepId,
      waiting: waiting,
    );
  }

  /// Get current connection status
  String? get connectedId => _connectedId;

  /// Clear connection status
  void clearConnection() {
    _connectedId = null;
  }
}
