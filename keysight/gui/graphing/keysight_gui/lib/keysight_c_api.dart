library c_api;

import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';
import 'dart:io';
import 'package:path/path.dart';

class KeysightCAPI extends ChangeNotifier {
  KeysightCAPI() {
    print("created shadow client");
    print("resolved exec path1: ${Platform.resolvedExecutable}");
    keysightCAPI = this;

    File exeFile = File("${Platform.resolvedExecutable}");
    String libPath = "${dirname(exeFile.path)}/$_LIBRARY_NAME";

    print("attempting to open library name: $libPath");
    final lib = ffi.DynamicLibrary.open(libPath);

    final initializeApi = lib.lookupFunction<
        ffi.IntPtr Function(ffi.Pointer<ffi.Void>),
        int Function(ffi.Pointer<ffi.Void>)>("InitializeDartApi");

    if (initializeApi(ffi.NativeApi.initializeApiDLData) != 0) {
      throw "Failed to initialize Dart API";
    }
  }

  static const String _LIBRARY_NAME = 'lib/libkeysight_backend.so';
}

KeysightCAPI? keysightCAPI;
