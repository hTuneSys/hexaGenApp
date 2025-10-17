// SPDX-FileCopyrightText: 2025 hexaTune LLC
// SPDX-License-Identifier: MIT

import 'dart:typed_data';
import 'package:hexagenapp/src/core/device/sysex.dart';

/// AT Command parser and builder for hexaTune devices
class ATCommand {
  /// Build AT+VERSION? command as raw MIDI bytes (SysEx format)
  /// Returns: F0 command_bytes F7
  static Uint8List buildVersionQuery() {
    final cmd = 'AT+VERSION?'; // No \r\n, no encoding
    return SysEx.buildSysEx(cmd); // Return raw bytes, NOT USB MIDI packets
  }

  /// Extract and parse AT response from MIDI data
  static ATResponse? extractAndParse(Uint8List data) {
    final message = SysEx.extractSysexPayload(data);
    if (message == null) return null;
    return parseResponse(message);
  }

  /// Parse AT response (plain text, no base64)
  /// Format: AT+ERROR=E001001
  ///         AT+VERSION=1.0.0
  ///         AT+OK
  static ATResponse? parseResponse(String message) {
    final trimmed = message.trim();

    if (trimmed.startsWith('AT+ERROR=')) {
      final errorCode = trimmed.substring(9).trim();
      return ATResponse(type: ATResponseType.error, errorCode: errorCode);
    } else if (trimmed.startsWith('AT+VERSION=')) {
      final version = trimmed.substring(11).trim();
      return ATResponse(type: ATResponseType.version, version: version);
    } else if (trimmed == 'AT+OK') {
      return ATResponse(type: ATResponseType.ok);
    }

    return null;
  }
}

/// AT Response types
enum ATResponseType { version, error, ok }

/// AT Response data
class ATResponse {
  final ATResponseType type;
  final String? version;
  final String? errorCode;

  ATResponse({required this.type, this.version, this.errorCode});
}
