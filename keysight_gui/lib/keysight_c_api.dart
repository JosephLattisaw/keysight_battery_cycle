library c_api;

import 'package:flutter/foundation.dart';
import 'dart:io' show File, Platform;
import 'dart:ffi' as ffi;
import 'package:path/path.dart';

class KeysightCAPI extends ChangeNotifier {
  KeysightCAPI() {
    if (kDebugMode) {
      print("resolved exec path1: ${Platform.resolvedExecutable}");
    }
    keysightCAPI = this;

    File exeFile = File(Platform.resolvedExecutable);

    String libPath = "";

    if (Platform.isLinux) {
      libPath = "${dirname(exeFile.path)}/lib/libkeysight_backend.so";
    } else if (Platform.isWindows) {
      libPath = "${dirname(exeFile.path)}\\keysight_backend.dll";
    } else {
      throw "Failed to find a platform suitable library";
    }

    if (kDebugMode) {
      print("attempting to open library name: $libPath");
    }

    final lib = ffi.DynamicLibrary.open(libPath);

    final initializeApi = lib.lookupFunction<
        ffi.IntPtr Function(ffi.Pointer<ffi.Void>),
        int Function(ffi.Pointer<ffi.Void>)>("InitializeDartApi");

    if (initializeApi(ffi.NativeApi.initializeApiDLData) != 0) {
      throw "Failed to initialize Dart API";
    }

    _createBackend = lib
        .lookup<ffi.NativeFunction<CreateBackendFFI>>("create_backend")
        .asFunction();

    _createBackend();
  }

  late CreateBackendC _createBackend;
}

KeysightCAPI? keysightCAPI;

//create backend
typedef CreateBackendFFI = ffi.Void Function();
typedef CreateBackendC = void Function();
