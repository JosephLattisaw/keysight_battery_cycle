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

    _createBackend = lib
        .lookup<ffi.NativeFunction<CreateBackend_FFI>>("create_backend")
        .asFunction();

    startSaveSequence = lib
        .lookup<ffi.NativeFunction<StartSaveSequence_FFI>>(
            "start_save_sequence")
        .asFunction();

    addSaveSequenceStep = lib
        .lookup<ffi.NativeFunction<AddSaveSequenceStep_FFI>>(
            "add_save_sequence_step")
        .asFunction();

    addSaveSequenceTest = lib
        .lookup<ffi.NativeFunction<AddSaveSequenceTest_FFI>>(
            "add_save_sequence_test")
        .asFunction();

    finishSaveSequence = lib
        .lookup<ffi.NativeFunction<Void_Function_FFI>>("finish_save_sequence")
        .asFunction();

    _createBackend(1);
  }

  late StartSaveSequence_C startSaveSequence;
  late AddSaveSequenceStep_C addSaveSequenceStep;
  late AddSaveSequenceTest_C addSaveSequenceTest;
  late Void_Function_C finishSaveSequence;
  late CreateBackend_C _createBackend;

  static const String _LIBRARY_NAME = 'lib/libkeysight_backend.so';
}

KeysightCAPI? keysightCAPI;

//FFI signature types
typedef Void_Function_FFI = ffi.Void Function();
typedef Void_Function_C = void Function();

//create backend
typedef CreateBackend_FFI = ffi.Void Function(ffi.Uint8);
typedef CreateBackend_C = void Function(int);

//start save sequence
typedef StartSaveSequence_FFI = ffi.Void Function(ffi.Pointer<Utf8> name,
    ffi.Pointer<Utf8> serial_number, ffi.Pointer<Utf8> comments);
typedef StartSaveSequence_C = void Function(ffi.Pointer<Utf8> name,
    ffi.Pointer<Utf8> serial_number, ffi.Pointer<Utf8> comments);

//add save sequence step
typedef AddSaveSequenceStep_FFI = ffi.Void Function(
    ffi.Int32 mode, ffi.Int32 seconds, ffi.Double current, ffi.Double voltage);
typedef AddSaveSequenceStep_C = void Function(
    int mode, int seconds, double current, double voltage);

//add save sequence test
typedef AddSaveSequenceTest_FFI = ffi.Void Function(
    ffi.Int32 testType,
    ffi.Int32 testAction,
    ffi.Double value,
    ffi.Int32 timeType,
    ffi.Int32 timeLimit);

typedef AddSaveSequenceTest_C = void Function(
    int testType, int testAction, double value, int timeType, int timeLimit);
