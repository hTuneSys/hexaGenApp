// SPDX-FileCopyrightText: 2025 hexaTune LLC
// SPDX-License-Identifier: MIT

import 'dart:typed_data';
import 'proto_service.dart';
import 'hexa_tune_proto_ffi.dart';

/// AT Response types
enum ATResponseType { version, error, done, status, operation, freq }

/// Device status from periodic STATUS messages
enum DeviceStatus { available, generating }

/// Command status for tracking
enum CommandStatus { pending, success, error, timeout }

/// Sent command tracking
class SentCommand {
  final int id;
  final String command;
  final DateTime sentAt;
  CommandStatus status;
  String? errorCode;

  SentCommand(
    this.id,
    this.command,
    this.sentAt,
    this.status, {
    this.errorCode,
  });
}

/// Notification item
class NotificationItem {
  final String message;
  final DateTime time;
  bool read;

  NotificationItem(this.message, this.time, {this.read = false});
}

/// AT Response data
class ATResponse {
  final ATResponseType type;
  final String id;
  final List<String> params;

  ATResponse({required this.type, required this.id, required this.params});

  /// Convenience getter for version response
  String get version => params.isNotEmpty ? params[0] : '';

  /// Convenience getter for error code
  String get errorCode => params.isNotEmpty ? params[0] : '';

  /// Convenience getter for device status
  DeviceStatus get status => params.isNotEmpty && params[0] == 'AVAILABLE'
      ? DeviceStatus.available
      : DeviceStatus.generating;

  /// Operation status getter
  /// Returns the actual operation status based on response format:
  /// - AT+OPERATION=id#PREPARE#COMPLETED -> returns "COMPLETED"
  /// - AT+OPERATION=id#GENERATE#COMPLETED -> returns "COMPLETED"
  /// - AT+OPERATION=id#GENERATING#stepId -> returns "GENERATING"
  String get operationStatus {
    if (params.isEmpty) return '';

    // If second param is COMPLETED, that's the status
    if (params.length > 1 && params[1] == 'COMPLETED') {
      return 'COMPLETED';
    }

    // Otherwise return first param (PREPARE, GENERATE, GENERATING, etc.)
    return params[0];
  }

  /// Step ID for GENERATING status (AT+OPERATION=id#GENERATING#stepId)
  int? get operationStepId {
    if (params.length > 1 && params[0] == 'GENERATING') {
      return int.tryParse(params[1]);
    }
    return null;
  }

  /// Check if FREQ command completed (AT+FREQ=stepId#freq#timeMs#COMPLETED)
  bool get freqCompleted {
    if (type == ATResponseType.freq && params.length >= 3) {
      return params[2] == 'COMPLETED';
    }
    return false;
  }

  /// Check if OPERATION command completed
  bool get operationCompleted {
    if (type == ATResponseType.operation && params.isNotEmpty) {
      return params.contains('COMPLETED');
    }
    return false;
  }
}

/// Parse AT response using FFI.
///
/// Drop-in replacement for the old Dart-only parseATResponse.
ATResponse? parseATResponse(String message) {
  final trimmed = message.trim();
  if (!trimmed.startsWith('AT+')) return null;

  try {
    final proto = ProtoService().proto;
    final input = Uint8List.fromList(trimmed.codeUnits);
    final result = proto.atParse(input);

    final id = result.id.toString();
    final params = result.params;

    switch (result.name) {
      case 'VERSION':
        return ATResponse(type: ATResponseType.version, id: id, params: params);
      case 'OPERATION':
        return ATResponse(
          type: ATResponseType.operation,
          id: id,
          params: params,
        );
      case 'FREQ':
        return ATResponse(type: ATResponseType.freq, id: id, params: params);
      case 'SETRGB':
        return ATResponse(type: ATResponseType.done, id: id, params: params);
      case 'RESET':
        return ATResponse(type: ATResponseType.done, id: id, params: params);
      case 'FWUPDATE':
        return ATResponse(type: ATResponseType.done, id: id, params: params);
      case 'ERROR':
        return ATResponse(type: ATResponseType.error, id: id, params: params);
      case 'DONE':
        return ATResponse(type: ATResponseType.done, id: id, params: params);
      case 'STATUS':
        return ATResponse(type: ATResponseType.status, id: id, params: params);
      default:
        return null;
    }
  } on HexaTuneProtoError {
    return null;
  } catch (_) {
    return null;
  }
}

/// Extract SysEx payload from MIDI data and parse AT response.
///
/// Handles both USB MIDI packet format (Android) and raw SysEx (iOS).
ATResponse? extractAndParseATResponse(Uint8List data) {
  try {
    final proto = ProtoService().proto;

    // Detect USB MIDI packet format vs raw SysEx
    final isUsbMidiPackets =
        data.length >= 4 && (data[0] & 0xF0) == 0x00 && data.length % 4 == 0;

    Uint8List payload;
    if (isUsbMidiPackets) {
      // Android: USB MIDI packets → depacketize → unframe
      final sysex = proto.usbDepacketize(data);
      payload = proto.sysexUnframe(sysex);
    } else {
      // iOS: Raw SysEx bytes → unframe directly
      payload = proto.sysexUnframe(data);
    }

    final message = String.fromCharCodes(payload);
    return parseATResponse(message);
  } on HexaTuneProtoError {
    return null;
  } catch (_) {
    return null;
  }
}
