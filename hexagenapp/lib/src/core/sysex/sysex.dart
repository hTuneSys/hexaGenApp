// SPDX-FileCopyrightText: 2025 hexaTune LLC
// SPDX-License-Identifier: MIT

import 'dart:typed_data';
import 'dart:convert' show utf8;

/// SysEx message utilities for MIDI communication
class SysEx {
  /// Build SysEx message from string payload
  static Uint8List buildSysEx(String payload) {
    final payloadBytes = utf8.encode(payload);
    final out = Uint8List(payloadBytes.length + 2);

    out[0] = 0xF0; // SysEx start
    for (int i = 0; i < payloadBytes.length; i++) {
      out[i + 1] = payloadBytes[i];
    }
    out[out.length - 1] = 0xF7; // SysEx end

    return out;
  }

  /// Convert SysEx to USB MIDI packets (4-byte format)
  /// Format: [CIN, byte1, byte2, byte3]
  /// CIN codes:
  ///   0x04 = SysEx start or continue (3 data bytes)
  ///   0x05 = SysEx end with 1 data byte
  ///   0x06 = SysEx end with 2 data bytes
  ///   0x07 = SysEx end with 3 data bytes
  static Uint8List sysexToUsbMidiPackets(Uint8List sysex) {
    final packets = <int>[];

    int i = 0;
    while (i < sysex.length) {
      final rem = sysex.length - i;

      if (rem >= 3) {
        // Check if this is the last 3 bytes and ends with 0xF7
        if (rem == 3 && sysex[sysex.length - 1] == 0xF7) {
          // End with 3 bytes
          packets.addAll([0x07, sysex[i], sysex[i + 1], sysex[i + 2]]);
          i += 3;
        } else {
          // Start or continue with 3 bytes
          packets.addAll([0x04, sysex[i], sysex[i + 1], sysex[i + 2]]);
          i += 3;
        }
      } else if (rem == 2) {
        // End with 2 bytes
        packets.addAll([0x06, sysex[i], sysex[i + 1], 0x00]);
        i += 2;
      } else {
        // End with 1 byte
        packets.addAll([0x05, sysex[i], 0x00, 0x00]);
        i += 1;
      }
    }

    return Uint8List.fromList(packets);
  }

  /// Extract SysEx payload from USB MIDI packets OR raw MIDI bytes
  /// Returns the payload without F0 and F7 markers
  static String? extractSysexPayload(Uint8List data) {
    // Check if this is USB MIDI packet format (4-byte chunks with CIN)
    // or raw MIDI bytes (starts with 0xF0)
    final isUsbMidiPackets = data.length >= 4 && (data[0] & 0xF0) == 0x00;

    if (isUsbMidiPackets) {
      return _extractFromUsbMidiPackets(data);
    } else {
      return _extractFromRawBytes(data);
    }
  }

  /// Extract from USB MIDI packet format
  static String? _extractFromUsbMidiPackets(Uint8List data) {
    final out = <int>[];

    // Process 4-byte chunks
    for (int i = 0; i < data.length; i += 4) {
      if (i + 3 >= data.length) break;

      final cin = data[i] & 0x0F;
      final b1 = data[i + 1];
      final b2 = data[i + 2];
      final b3 = data[i + 3];

      switch (cin) {
        case 0x04: // SysEx continue/start (3 bytes)
          if (b1 != 0) out.add(b1);
          if (b2 != 0) out.add(b2);
          if (b3 != 0) out.add(b3);
          break;

        case 0x05: // End with 1 byte
          if (b1 != 0) out.add(b1);
          break;

        case 0x06: // End with 2 bytes
          if (b1 != 0) out.add(b1);
          if (b2 != 0) out.add(b2);
          break;

        case 0x07: // End with 3 bytes
          if (b1 != 0) out.add(b1);
          if (b2 != 0) out.add(b2);
          if (b3 != 0) out.add(b3);
          break;
      }
    }

    // Check for F0 and F7 markers
    if (out.isEmpty || out.first != 0xF0 || out.last != 0xF7) {
      return null;
    }

    // Extract payload (remove F0 and F7)
    final payload = out.sublist(1, out.length - 1);

    try {
      return utf8.decode(payload, allowMalformed: true);
    } catch (e) {
      return null;
    }
  }

  /// Extract from raw MIDI bytes
  static String? _extractFromRawBytes(Uint8List data) {
    // Check for F0 and F7 markers
    if (data.isEmpty || data.first != 0xF0) {
      return null;
    }

    // Find F7 end marker
    int endIndex = -1;
    for (int i = 0; i < data.length; i++) {
      if (data[i] == 0xF7) {
        endIndex = i;
        break;
      }
    }

    if (endIndex == -1) {
      return null; // No end marker found
    }

    // Extract payload (between F0 and F7)
    if (endIndex <= 1) {
      return null; // No payload
    }

    final payload = data.sublist(1, endIndex);

    try {
      return utf8.decode(payload, allowMalformed: true);
    } catch (e) {
      return null;
    }
  }
}
