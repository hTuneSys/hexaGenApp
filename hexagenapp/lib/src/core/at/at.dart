// SPDX-FileCopyrightText: 2025 hexaTune LLC
// SPDX-License-Identifier: MIT

import 'dart:typed_data';
import 'package:hexagenapp/src/core/sysex/sysex.dart';

/// AT Command types
enum ATCommandType { version, freq, setRgb, reset, fwUpdate, operation }

/// AT Command class for building commands generically
class ATCommand {
  final int id;
  final ATCommandType type;
  final List<String> params;
  final bool isQuery;

  ATCommand(this.id, this.type, this.params, {this.isQuery = false});

  /// Compile the command to string
  /// Query format: AT+COMMAND?
  /// Command with params: AT+COMMAND=id#PARAM1#PARAM2...
  /// Command without params: AT+COMMAND=id
  String compile() {
    final name = type.name.toUpperCase();

    if (isQuery) {
      // Query format: AT+COMMAND?
      return 'AT+$name?';
    } else if (params.isEmpty) {
      // Command without params: AT+COMMAND=id
      return 'AT+$name=$id';
    } else {
      // Command with params: AT+COMMAND=id#PARAM1#PARAM2...
      final paramStr = [id.toString(), ...params].join('#');
      return 'AT+$name=$paramStr';
    }
  }

  /// Build as SysEx bytes
  Uint8List buildSysEx() {
    return SysEx.buildSysEx(compile());
  }

  /// Factory for version query
  factory ATCommand.version() {
    return ATCommand(0, ATCommandType.version, [], isQuery: true);
  }

  /// Factory for operation query (AT+OPERATION?)
  factory ATCommand.operationQuery() {
    return ATCommand(0, ATCommandType.operation, [], isQuery: true);
  }

  /// Factory for operation prepare (AT+OPERATION=id#PREPARE)
  factory ATCommand.operationPrepare(int id) {
    return ATCommand(id, ATCommandType.operation, ['PREPARE']);
  }

  /// Factory for operation generate (AT+OPERATION=id#GENERATE)
  factory ATCommand.operationGenerate(int id) {
    return ATCommand(id, ATCommandType.operation, ['GENERATE']);
  }

  /// Factory for freq command
  factory ATCommand.freq(int id, int freq, int timeMs) {
    return ATCommand(id, ATCommandType.freq, [
      freq.toString(),
      timeMs.toString(),
    ]);
  }

  /// Factory for setRgb command
  factory ATCommand.setRgb(int id, int r, int g, int b) {
    return ATCommand(id, ATCommandType.setRgb, [
      r.toString(),
      g.toString(),
      b.toString(),
    ]);
  }

  /// Factory for reset command (AT+RESET=id)
  factory ATCommand.reset(int id) {
    return ATCommand(id, ATCommandType.reset, []);
  }

  /// Factory for fwUpdate command (AT+FWUPDATE=id)
  factory ATCommand.fwUpdate(int id) {
    return ATCommand(id, ATCommandType.fwUpdate, []);
  }
}

/// Extract and parse AT response from MIDI data
ATResponse? extractAndParseATResponse(Uint8List data) {
  final message = SysEx.extractSysexPayload(data);
  if (message == null) return null;
  return parseATResponse(message);
}

/// Parse AT response
/// Formats:
/// AT+VERSION=0#version
/// AT+ERROR=id#error_code
/// AT+DONE=id (firmware has DONE response, but no DONE command)
/// AT+STATUS=0#AVAILABLE or GENERATING
/// AT+OPERATION=id#PREPARE#COMPLETED
/// AT+OPERATION=id#GENERATE#COMPLETED
/// AT+OPERATION=id#GENERATING#stepId
/// AT+FREQ=stepId#freq#timeMs#COMPLETED
ATResponse? parseATResponse(String message) {
  final trimmed = message.trim();
  if (!trimmed.startsWith('AT+')) return null;

  final cmd = trimmed.substring(3);
  final eqPos = cmd.indexOf('=');
  if (eqPos == -1) return null;

  final name = cmd.substring(0, eqPos);
  final paramStr = cmd.substring(eqPos + 1);
  final parts = paramStr.split('#');
  if (parts.isEmpty) return null;

  final id = parts[0];
  final params = parts.length > 1 ? parts.sublist(1) : <String>[];

  switch (name) {
    case 'VERSION':
      return ATResponse(type: ATResponseType.version, id: id, params: params);
    case 'OPERATION':
      return ATResponse(type: ATResponseType.operation, id: id, params: params);
    case 'FREQ':
      return ATResponse(type: ATResponseType.freq, id: id, params: params);
    case 'SETRGB':
      return ATResponse(
        type: ATResponseType.done,
        id: id,
        params: params,
      ); // Assuming DONE for SETRGB
    case 'RESET':
      return ATResponse(
        type: ATResponseType.done,
        id: id,
        params: params,
      ); // Assuming DONE for RESET
    case 'FWUPDATE':
      return ATResponse(
        type: ATResponseType.done,
        id: id,
        params: params,
      ); // Assuming DONE for FWUPDATE
    case 'ERROR':
      return ATResponse(type: ATResponseType.error, id: id, params: params);
    case 'DONE':
      return ATResponse(type: ATResponseType.done, id: id, params: params);
    case 'STATUS':
      return ATResponse(type: ATResponseType.status, id: id, params: params);
    default:
      return null;
  }
}

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
