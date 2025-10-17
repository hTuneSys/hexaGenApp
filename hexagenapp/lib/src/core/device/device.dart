// SPDX-FileCopyrightText: 2025 hexaTune LLC
// SPDX-License-Identifier: MIT

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:hexagenapp/src/core/error/error.dart';
import 'package:hexagenapp/src/core/device/at.dart';
import 'package:hexagenapp/src/core/device/sysex.dart';
import 'package:hexagenapp/src/core/service/log_service.dart';

/// Device response callback
typedef DeviceResponseCallback =
    void Function({String? version, AppError? error, required bool waiting});

/// HexaTune device manager
class HexaTuneDeviceManager {
  final MidiCommand _midi = MidiCommand();
  final RegExp _hexaPattern = RegExp(r'hexatune', caseSensitive: false);

  StreamSubscription<dynamic>? _setupSub;
  StreamSubscription<dynamic>? _dataSub;

  bool _connecting = false;
  String? _connectedId;
  bool _waitingForResponse = false;
  Timer? _responseTimeout;
  final List<int> _sysexBuffer = []; // SysEx mesaj buffer

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
        // Extra delay - cihazın firmware'inin hazır olması için
        // Firmware birden fazla task başlatıyor, hazır olması ~1-2 saniye sürebilir
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
    final bytes = ATCommand.buildVersionQuery();
    _waitingForResponse = true;
    _sysexBuffer.clear();
    _notifyResponse(version: null, error: null, waiting: true);

    logger.midi('Sending AT+VERSION? command (${bytes.length} bytes)');

    _midi.sendData(bytes, deviceId: deviceId);

    // Set timeout - 10 saniye yanıt gelmezse
    _responseTimeout?.cancel();
    _responseTimeout = Timer(const Duration(seconds: 10), () {
      if (_waitingForResponse) {
        logger.warning(
          'AT+VERSION? response timeout',
          category: LogCategory.midi,
        );
        _waitingForResponse = false;
        _sysexBuffer.clear();
        _notifyResponse(version: 'No response', error: null, waiting: false);
      }
    });
  }

  /// Handle AT command response
  void _handleATResponse(Uint8List bytes) {
    if (!_waitingForResponse) return;

    logger.midi('Received MIDI data: ${bytes.length} bytes');

    // Buffer'a ekle
    _sysexBuffer.addAll(bytes);

    // F7 (SysEx end) geldi mi kontrol et
    final hasEndMarker = _sysexBuffer.contains(0xF7);

    if (!hasEndMarker) {
      logger.debug(
        'Waiting for more data (buffer: ${_sysexBuffer.length} bytes)',
        category: LogCategory.midi,
      );
      return; // Daha fazla veri bekle
    }

    // Cancel timeout
    _responseTimeout?.cancel();

    try {
      final bufferedData = Uint8List.fromList(_sysexBuffer);
      final message = SysEx.extractSysexPayload(bufferedData);

      // Buffer'ı temizle
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

      final response = ATCommand.parseResponse(message);

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
            'AT Error: ${response.errorCode}',
            category: LogCategory.midi,
          );
          final error = AppErrorExtension.fromCode(response.errorCode ?? '');
          _notifyResponse(version: null, error: error, waiting: false);
          break;

        case ATResponseType.version:
          logger.info(
            'AT Version: ${response.version}',
            category: LogCategory.midi,
          );
          _notifyResponse(
            version: response.version,
            error: null,
            waiting: false,
          );
          break;

        case ATResponseType.ok:
          logger.info('AT OK received', category: LogCategory.midi);
          _notifyResponse(version: 'OK', error: null, waiting: false);
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
    required bool waiting,
  }) {
    _responseCallback?.call(version: version, error: error, waiting: waiting);
  }

  /// Get current connection status
  String? get connectedId => _connectedId;

  /// Clear connection status
  void clearConnection() {
    _connectedId = null;
  }
}
