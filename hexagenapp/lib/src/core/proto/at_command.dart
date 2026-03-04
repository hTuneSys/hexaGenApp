// SPDX-FileCopyrightText: 2025 hexaTune LLC
// SPDX-License-Identifier: MIT

import 'dart:typed_data';
import 'proto_service.dart';
import 'hexa_tune_proto_ffi.dart';

/// AT Command types
enum ATCommandType { version, freq, setRgb, reset, fwUpdate, operation }

/// AT Command class for building commands generically.
///
/// Drop-in replacement for the old Dart-only ATCommand.
/// Encoding is now performed via FFI to the Rust hexaTuneProto library.
class ATCommand {
  final int id;
  final ATCommandType type;
  final List<String> params;
  final bool isQuery;

  ATCommand(this.id, this.type, this.params, {this.isQuery = false});

  /// Compile the command to string (for logging/debug).
  /// Query format: AT+COMMAND?
  /// Command with params: AT+COMMAND=id#PARAM1#PARAM2...
  /// Command without params: AT+COMMAND=id
  String compile() {
    final name = type.name.toUpperCase();

    if (isQuery) {
      return 'AT+$name?';
    } else if (params.isEmpty) {
      return 'AT+$name=$id';
    } else {
      final paramStr = [id.toString(), ...params].join('#');
      return 'AT+$name=$paramStr';
    }
  }

  /// Build as SysEx bytes via FFI (F0...F7) — for flutter_midi_command sendData
  Uint8List buildSysEx() {
    final proto = ProtoService().proto;
    final name = type.name.toUpperCase();
    final atBytes = proto.atEncode(
      name,
      id: id,
      op: isQuery ? AtOp.query : AtOp.set,
      params: params,
    );
    return proto.sysexFrame(atBytes);
  }

  /// Build as USB MIDI packets via FFI (full pipeline)
  Uint8List buildPackets() {
    final proto = ProtoService().proto;
    final name = type.name.toUpperCase();
    return proto.encodeToPackets(
      name,
      id: id,
      op: isQuery ? AtOp.query : AtOp.set,
      params: params,
    );
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
