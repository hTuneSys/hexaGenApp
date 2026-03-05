// SPDX-FileCopyrightText: 2026 hexaTune LLC
// SPDX-License-Identifier: MIT

/// Dart FFI bindings for hexaTuneProto.
///
/// This file provides a type-safe Dart wrapper around the C ABI exported
/// by `hexa-tune-proto-ffi`. All protocol encoding/decoding is performed
/// in Rust — Dart only calls through FFI.
///
/// Usage:
/// ```dart
/// final proto = HexaTuneProto('libhexa_tune_proto_ffi.so');
/// final packets = proto.encodeToPackets('FREQ', id: 5, params: ['440', '1000']);
/// final response = proto.parseAt(responseBytes);
/// ```
library hexa_tune_proto_ffi;

import 'dart:ffi';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';

// ---------------------------------------------------------------------------
// Native struct definitions (mirror C structs)
// ---------------------------------------------------------------------------

/// Mirrors `HtpSlice` — a pointer + length pair.
final class HtpSlice extends Struct {
  external Pointer<Uint8> ptr;

  @IntPtr()
  external int len;
}

/// Mirrors `HtpAtParseResult` — parse output with offsets into input buffer.
final class HtpAtParseResult extends Struct {
  @Uint32()
  external int id;

  @Int32()
  external int op;

  @IntPtr()
  external int nameOffset;

  @IntPtr()
  external int nameLen;

  @IntPtr()
  external int paramCount;

  @Array(8)
  external Array<IntPtr> paramOffsets;

  @Array(8)
  external Array<IntPtr> paramLens;
}

// ---------------------------------------------------------------------------
// Native function typedefs
// ---------------------------------------------------------------------------

typedef _HtpAtEncodeNative = Int32 Function(
  Pointer<Uint8> namePtr,
  IntPtr nameLen,
  Uint32 id,
  Int32 op,
  Pointer<HtpSlice> paramsPtr,
  IntPtr paramsCount,
  Pointer<Uint8> outPtr,
  IntPtr outCap,
  Pointer<IntPtr> outLen,
);
typedef _HtpAtEncodeDart = int Function(
  Pointer<Uint8> namePtr,
  int nameLen,
  int id,
  int op,
  Pointer<HtpSlice> paramsPtr,
  int paramsCount,
  Pointer<Uint8> outPtr,
  int outCap,
  Pointer<IntPtr> outLen,
);

typedef _HtpAtParseNative = Int32 Function(
  Pointer<Uint8> inputPtr,
  IntPtr inputLen,
  Pointer<HtpAtParseResult> result,
);
typedef _HtpAtParseDart = int Function(
  Pointer<Uint8> inputPtr,
  int inputLen,
  Pointer<HtpAtParseResult> result,
);

typedef _HtpSysexFrameNative = Int32 Function(
  Pointer<Uint8> payloadPtr,
  IntPtr payloadLen,
  Pointer<Uint8> outPtr,
  IntPtr outCap,
  Pointer<IntPtr> outLen,
);
typedef _HtpSysexFrameDart = int Function(
  Pointer<Uint8> payloadPtr,
  int payloadLen,
  Pointer<Uint8> outPtr,
  int outCap,
  Pointer<IntPtr> outLen,
);

typedef _HtpSysexUnframeNative = Int32 Function(
  Pointer<Uint8> dataPtr,
  IntPtr dataLen,
  Pointer<IntPtr> outOffset,
  Pointer<IntPtr> outLen,
);
typedef _HtpSysexUnframeDart = int Function(
  Pointer<Uint8> dataPtr,
  int dataLen,
  Pointer<IntPtr> outOffset,
  Pointer<IntPtr> outLen,
);

typedef _HtpUsbPacketizeNative = Int32 Function(
  Pointer<Uint8> sysexPtr,
  IntPtr sysexLen,
  Pointer<Uint8> outPtr, // Pointer to [u8;4] array treated as flat bytes
  IntPtr outCap,
  Pointer<IntPtr> outCount,
);
typedef _HtpUsbPacketizeDart = int Function(
  Pointer<Uint8> sysexPtr,
  int sysexLen,
  Pointer<Uint8> outPtr,
  int outCap,
  Pointer<IntPtr> outCount,
);

typedef _HtpUsbDepacketizeNative = Int32 Function(
  Pointer<Uint8> packetsPtr, // flat [u8;4] × N
  IntPtr packetCount,
  Pointer<Uint8> outPtr,
  IntPtr outCap,
  Pointer<IntPtr> outLen,
);
typedef _HtpUsbDepacketizeDart = int Function(
  Pointer<Uint8> packetsPtr,
  int packetCount,
  Pointer<Uint8> outPtr,
  int outCap,
  Pointer<IntPtr> outLen,
);

typedef _HtpEncodeToPacketsNative = Int32 Function(
  Pointer<Uint8> namePtr,
  IntPtr nameLen,
  Uint32 id,
  Int32 op,
  Pointer<HtpSlice> paramsPtr,
  IntPtr paramsCount,
  Pointer<Uint8> atBufPtr,
  IntPtr atBufCap,
  Pointer<Uint8> sysexBufPtr,
  IntPtr sysexBufCap,
  Pointer<Uint8> packetsOutPtr, // flat [u8;4] × N
  IntPtr packetsOutCap,
  Pointer<IntPtr> packetsOutCount,
);
typedef _HtpEncodeToPacketsDart = int Function(
  Pointer<Uint8> namePtr,
  int nameLen,
  int id,
  int op,
  Pointer<HtpSlice> paramsPtr,
  int paramsCount,
  Pointer<Uint8> atBufPtr,
  int atBufCap,
  Pointer<Uint8> sysexBufPtr,
  int sysexBufCap,
  Pointer<Uint8> packetsOutPtr,
  int packetsOutCap,
  Pointer<IntPtr> packetsOutCount,
);

// ---------------------------------------------------------------------------
// AT operation enum (mirrors Rust AtOp)
// ---------------------------------------------------------------------------

/// AT command operation type.
enum AtOp {
  set(0),
  query(1),
  response(2);

  const AtOp(this.value);
  final int value;
}

// ---------------------------------------------------------------------------
// Parsed AT message (high-level result)
// ---------------------------------------------------------------------------

/// Parsed AT command result returned by [HexaTuneProto.parseAt].
class AtParseResult {
  final String name;
  final int id;
  final AtOp op;
  final List<String> params;

  const AtParseResult({
    required this.name,
    required this.id,
    required this.op,
    required this.params,
  });

  @override
  String toString() => 'AtParseResult(name=$name, id=$id, op=$op, params=$params)';
}

// ---------------------------------------------------------------------------
// Proto error
// ---------------------------------------------------------------------------

/// Error thrown when a native htp_* function returns a negative code.
class HexaTuneProtoError implements Exception {
  final int code;
  final String function;

  HexaTuneProtoError(this.code, this.function);

  static const _errorNames = <int, String>{
    1: 'BufferTooSmall',
    2: 'InvalidSysex',
    3: 'InvalidAtCommand',
    4: 'InvalidId',
    5: 'PayloadNotUtf8',
    6: 'InvalidPacket',
    7: 'Overflow',
    8: 'EmptyInput',
    9: 'MissingPrefix',
    10: 'MissingOperator',
  };

  String get name => _errorNames[code] ?? 'Unknown($code)';

  @override
  String toString() => 'HexaTuneProtoError: $name (code=$code) in $function';
}

// ---------------------------------------------------------------------------
// Main API class
// ---------------------------------------------------------------------------

/// High-level Dart interface to the hexaTuneProto native library.
///
/// Wraps all `htp_*` C functions with safe Dart types.
class HexaTuneProto {
  late final DynamicLibrary _lib;

  late final _HtpAtEncodeDart _atEncode;
  late final _HtpAtParseDart _atParse;
  late final _HtpSysexFrameDart _sysexFrame;
  late final _HtpSysexUnframeDart _sysexUnframe;
  late final _HtpUsbPacketizeDart _usbPacketize;
  late final _HtpUsbDepacketizeDart _usbDepacketize;
  late final _HtpEncodeToPacketsDart _encodeToPackets;

  /// Load the native library from the given [path].
  ///
  /// On Android this is typically `'libhexa_tune_proto_ffi.so'`.
  /// On iOS the library is statically linked — use [HexaTuneProto.open].
  HexaTuneProto(String path) : _lib = DynamicLibrary.open(path) {
    _bindAll();
  }

  /// Use the process-level symbols (iOS static linking).
  HexaTuneProto.open() : _lib = DynamicLibrary.process() {
    _bindAll();
  }

  void _bindAll() {
    _atEncode = _lib
        .lookupFunction<_HtpAtEncodeNative, _HtpAtEncodeDart>('htp_at_encode');
    _atParse = _lib
        .lookupFunction<_HtpAtParseNative, _HtpAtParseDart>('htp_at_parse');
    _sysexFrame = _lib
        .lookupFunction<_HtpSysexFrameNative, _HtpSysexFrameDart>('htp_sysex_frame');
    _sysexUnframe = _lib
        .lookupFunction<_HtpSysexUnframeNative, _HtpSysexUnframeDart>('htp_sysex_unframe');
    _usbPacketize = _lib
        .lookupFunction<_HtpUsbPacketizeNative, _HtpUsbPacketizeDart>('htp_usb_packetize');
    _usbDepacketize = _lib
        .lookupFunction<_HtpUsbDepacketizeNative, _HtpUsbDepacketizeDart>('htp_usb_depacketize');
    _encodeToPackets = _lib
        .lookupFunction<_HtpEncodeToPacketsNative, _HtpEncodeToPacketsDart>('htp_encode_to_packets');
  }

  // -------------------------------------------------------------------------
  // AT encode
  // -------------------------------------------------------------------------

  /// Encode an AT command string.
  ///
  /// Returns the encoded bytes (e.g. `AT+FREQ=5#440#1000`).
  Uint8List atEncode(
    String name, {
    int id = 0,
    AtOp op = AtOp.set,
    List<String> params = const [],
  }) {
    final nameBytes = name.codeUnits;
    final namePtr = calloc<Uint8>(nameBytes.length);
    final outPtr = calloc<Uint8>(512);
    final outLen = calloc<IntPtr>(1);

    // Copy name
    for (var i = 0; i < nameBytes.length; i++) {
      namePtr[i] = nameBytes[i];
    }

    // Build params
    Pointer<HtpSlice> paramsPtr = nullptr;
    final paramPtrs = <Pointer<Uint8>>[];

    if (params.isNotEmpty) {
      paramsPtr = calloc<HtpSlice>(params.length);
      for (var i = 0; i < params.length; i++) {
        final bytes = params[i].codeUnits;
        final p = calloc<Uint8>(bytes.length);
        for (var j = 0; j < bytes.length; j++) {
          p[j] = bytes[j];
        }
        paramPtrs.add(p);
        paramsPtr[i].ptr = p;
        paramsPtr[i].len = bytes.length;
      }
    }

    try {
      final rc = _atEncode(
        namePtr, nameBytes.length,
        id, op.value,
        paramsPtr, params.length,
        outPtr, 512, outLen,
      );
      if (rc < 0) throw HexaTuneProtoError(-rc, 'htp_at_encode');
      return Uint8List.fromList(outPtr.asTypedList(outLen.value));
    } finally {
      calloc.free(namePtr);
      calloc.free(outPtr);
      calloc.free(outLen);
      for (final p in paramPtrs) {
        calloc.free(p);
      }
      if (paramsPtr != nullptr) calloc.free(paramsPtr);
    }
  }

  // -------------------------------------------------------------------------
  // AT parse
  // -------------------------------------------------------------------------

  /// Parse an AT command from raw bytes.
  AtParseResult atParse(Uint8List input) {
    final inputPtr = calloc<Uint8>(input.length);
    final resultPtr = calloc<HtpAtParseResult>(1);

    for (var i = 0; i < input.length; i++) {
      inputPtr[i] = input[i];
    }

    try {
      final rc = _atParse(inputPtr, input.length, resultPtr);
      if (rc < 0) throw HexaTuneProtoError(-rc, 'htp_at_parse');

      final r = resultPtr.ref;
      final name = String.fromCharCodes(
        input.sublist(r.nameOffset, r.nameOffset + r.nameLen),
      );
      final params = <String>[];
      for (var i = 0; i < r.paramCount; i++) {
        final off = r.paramOffsets[i];
        final len = r.paramLens[i];
        params.add(String.fromCharCodes(input.sublist(off, off + len)));
      }

      return AtParseResult(
        name: name,
        id: r.id,
        op: AtOp.values.firstWhere((e) => e.value == r.op),
        params: params,
      );
    } finally {
      calloc.free(inputPtr);
      calloc.free(resultPtr);
    }
  }

  // -------------------------------------------------------------------------
  // SysEx frame / unframe
  // -------------------------------------------------------------------------

  /// Frame payload bytes into a SysEx message (F0 … payload … F7).
  Uint8List sysexFrame(Uint8List payload) {
    final inPtr = calloc<Uint8>(payload.length);
    final outPtr = calloc<Uint8>(payload.length + 2);
    final outLen = calloc<IntPtr>(1);

    for (var i = 0; i < payload.length; i++) {
      inPtr[i] = payload[i];
    }

    try {
      final rc = _sysexFrame(
        inPtr, payload.length,
        outPtr, payload.length + 2, outLen,
      );
      if (rc < 0) throw HexaTuneProtoError(-rc, 'htp_sysex_frame');
      return Uint8List.fromList(outPtr.asTypedList(outLen.value));
    } finally {
      calloc.free(inPtr);
      calloc.free(outPtr);
      calloc.free(outLen);
    }
  }

  /// Extract payload from a SysEx message.
  Uint8List sysexUnframe(Uint8List data) {
    final inPtr = calloc<Uint8>(data.length);
    final outOffset = calloc<IntPtr>(1);
    final outLen = calloc<IntPtr>(1);

    for (var i = 0; i < data.length; i++) {
      inPtr[i] = data[i];
    }

    try {
      final rc = _sysexUnframe(inPtr, data.length, outOffset, outLen);
      if (rc < 0) throw HexaTuneProtoError(-rc, 'htp_sysex_unframe');
      final offset = outOffset.value;
      final length = outLen.value;
      return Uint8List.fromList(data.sublist(offset, offset + length));
    } finally {
      calloc.free(inPtr);
      calloc.free(outOffset);
      calloc.free(outLen);
    }
  }

  // -------------------------------------------------------------------------
  // USB MIDI packetize / depacketize
  // -------------------------------------------------------------------------

  /// Convert SysEx bytes to USB MIDI 4-byte packets.
  ///
  /// Returns a flat [Uint8List] of length `packetCount * 4`.
  Uint8List usbPacketize(Uint8List sysex) {
    final maxPackets = (sysex.length ~/ 3) + 2;
    final inPtr = calloc<Uint8>(sysex.length);
    final outPtr = calloc<Uint8>(maxPackets * 4);
    final outCount = calloc<IntPtr>(1);

    for (var i = 0; i < sysex.length; i++) {
      inPtr[i] = sysex[i];
    }

    try {
      final rc = _usbPacketize(
        inPtr, sysex.length,
        outPtr, maxPackets, outCount,
      );
      if (rc < 0) throw HexaTuneProtoError(-rc, 'htp_usb_packetize');
      final count = outCount.value;
      return Uint8List.fromList(outPtr.asTypedList(count * 4));
    } finally {
      calloc.free(inPtr);
      calloc.free(outPtr);
      calloc.free(outCount);
    }
  }

  /// Reassemble SysEx bytes from USB MIDI 4-byte packets.
  ///
  /// [packets] must be a flat byte list of length `packetCount * 4`.
  Uint8List usbDepacketize(Uint8List packets) {
    assert(packets.length % 4 == 0, 'packets length must be multiple of 4');
    final packetCount = packets.length ~/ 4;
    final inPtr = calloc<Uint8>(packets.length);
    final outPtr = calloc<Uint8>(packetCount * 3 + 2);
    final outLen = calloc<IntPtr>(1);

    for (var i = 0; i < packets.length; i++) {
      inPtr[i] = packets[i];
    }

    try {
      final rc = _usbDepacketize(
        inPtr, packetCount,
        outPtr, packetCount * 3 + 2, outLen,
      );
      if (rc < 0) throw HexaTuneProtoError(-rc, 'htp_usb_depacketize');
      return Uint8List.fromList(outPtr.asTypedList(outLen.value));
    } finally {
      calloc.free(inPtr);
      calloc.free(outPtr);
      calloc.free(outLen);
    }
  }

  // -------------------------------------------------------------------------
  // Full pipeline
  // -------------------------------------------------------------------------

  /// Encode AT command → SysEx → USB MIDI packets in one call.
  ///
  /// Returns flat packet bytes (length = packetCount * 4).
  Uint8List encodeToPackets(
    String name, {
    int id = 0,
    AtOp op = AtOp.set,
    List<String> params = const [],
  }) {
    final nameBytes = name.codeUnits;
    final namePtr = calloc<Uint8>(nameBytes.length);
    final atBuf = calloc<Uint8>(512);
    final sysexBuf = calloc<Uint8>(514);
    final packetsBuf = calloc<Uint8>(256 * 4);
    final packetsCount = calloc<IntPtr>(1);

    for (var i = 0; i < nameBytes.length; i++) {
      namePtr[i] = nameBytes[i];
    }

    Pointer<HtpSlice> paramsPtr = nullptr;
    final paramPtrs = <Pointer<Uint8>>[];

    if (params.isNotEmpty) {
      paramsPtr = calloc<HtpSlice>(params.length);
      for (var i = 0; i < params.length; i++) {
        final bytes = params[i].codeUnits;
        final p = calloc<Uint8>(bytes.length);
        for (var j = 0; j < bytes.length; j++) {
          p[j] = bytes[j];
        }
        paramPtrs.add(p);
        paramsPtr[i].ptr = p;
        paramsPtr[i].len = bytes.length;
      }
    }

    try {
      final rc = _encodeToPackets(
        namePtr, nameBytes.length,
        id, op.value,
        paramsPtr, params.length,
        atBuf, 512,
        sysexBuf, 514,
        packetsBuf, 256,
        packetsCount,
      );
      if (rc < 0) throw HexaTuneProtoError(-rc, 'htp_encode_to_packets');
      final count = packetsCount.value;
      return Uint8List.fromList(packetsBuf.asTypedList(count * 4));
    } finally {
      calloc.free(namePtr);
      calloc.free(atBuf);
      calloc.free(sysexBuf);
      calloc.free(packetsBuf);
      calloc.free(packetsCount);
      for (final p in paramPtrs) {
        calloc.free(p);
      }
      if (paramsPtr != nullptr) calloc.free(paramsPtr);
    }
  }
}
