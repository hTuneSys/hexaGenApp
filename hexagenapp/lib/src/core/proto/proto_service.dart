// SPDX-FileCopyrightText: 2025 hexaTune LLC
// SPDX-License-Identifier: MIT

import 'dart:io' show Platform;
import 'hexa_tune_proto_ffi.dart';

/// Singleton service that loads and holds the native hexaTuneProto FFI instance.
class ProtoService {
  static final ProtoService _instance = ProtoService._internal();
  factory ProtoService() => _instance;

  late final HexaTuneProto _proto;

  ProtoService._internal() {
    if (Platform.isAndroid) {
      _proto = HexaTuneProto('libhexa_tune_proto_ffi.so');
    } else if (Platform.isIOS) {
      _proto = HexaTuneProto.open();
    } else {
      throw UnsupportedError('Platform not supported for hexaTuneProto FFI');
    }
  }

  /// The native protocol instance.
  HexaTuneProto get proto => _proto;
}
