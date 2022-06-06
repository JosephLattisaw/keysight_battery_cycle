library c_api;

import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show File, Platform;
import 'dart:ffi' as ffi;
import 'package:path/path.dart';

import '../sequence_api/seqeunce_c_api.dart';
import '../sequence_api/sequences.dart' as s_api;

class KeysightCAPI extends ChangeNotifier {
  KeysightCAPI() {
    if (kDebugMode) {
      print("resolved exec path1: ${Platform.resolvedExecutable}");
    }
    keysightCAPI = this;

    File exeFile = File(Platform.resolvedExecutable);

    String libPath = "";

    //check that we are running a compatible platform and set the library path accordingly
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

    final lib = ffi.DynamicLibrary.open(libPath); //loading the library

    final initializeApi = lib.lookupFunction<
        ffi.IntPtr Function(ffi.Pointer<ffi.Void>),
        int Function(ffi.Pointer<ffi.Void>)>("InitializeDartApi");

    if (initializeApi(ffi.NativeApi.initializeApiDLData) != 0) {
      throw "Failed to initialize Dart API";
    }

    _createBackend = lib
        .lookup<ffi.NativeFunction<CreateBackendFFI>>("create_backend")
        .asFunction();

    _runService = lib
        .lookup<ffi.NativeFunction<VoidFunctionFFI>>("run_service")
        .asFunction();

    _getSequences = lib
        .lookup<ffi.NativeFunction<SequencesFFI>>("get_sequences")
        .asFunction();

    connectKeysight = lib
        .lookup<ffi.NativeFunction<VoidFunctionFFI>>("connect_keysight")
        .asFunction();

    disconnectKeysight = lib
        .lookup<ffi.NativeFunction<VoidFunctionFFI>>("disconnect_keysight")
        .asFunction();

    ReceivePort keysightConnectionPort = ReceivePort()
      ..listen((message) {
        print("received keysight connection status $message");
        keysightConnectionStatus = message;
      });

    int keysightConnectionNativePort =
        keysightConnectionPort.sendPort.nativePort;

    _createBackend(keysightConnectionNativePort); //creating our backend
    _runService(); //running the asyncronous service

    final sequences = getSequences(); //TODO do we need?
    print("printing this total sequences: ${sequences.sequences.length}");
  }

//TODO figure out how to free pointers
  s_api.Sequences getSequences() {
    final sequences = _getSequences();

    final sequencesDart = List<s_api.Sequence>.empty(growable: true);

    for (int i = 0; i < sequences.size; i++) {
      final sequence =
          sequences.sequences.elementAt(i).cast<ffi.Pointer<Sequence>>().value;

      final stepsDart = List<s_api.Step>.empty(growable: true);

      for (int k = 0; k < sequence.ref.stepsSize; k++) {
        final step =
            sequence.ref.steps.elementAt(k).cast<ffi.Pointer<Step>>().value;

        final testsDart = List<s_api.Test>.empty(growable: true);

        for (int j = 0; j < step.ref.testsSize; j++) {
          final test =
              step.ref.tests.elementAt(j).cast<ffi.Pointer<Test>>().value;

          final testDart = s_api.Test(
              testAction: test.ref.testAction,
              testType: test.ref.testType,
              timeLimit: test.ref.timeLimit,
              timeType: test.ref.timeType,
              value: test.ref.value);

          testsDart.add(testDart);
        }

        final stepDart = s_api.Step(
            current: step.ref.current,
            mode: step.ref.mode,
            seconds: step.ref.seconds,
            voltage: step.ref.voltage,
            tests: testsDart);

        stepsDart.add(stepDart);
      }

      final sequenceDart = s_api.Sequence(
          comments: sequence.ref.comments.toDartString(),
          name: sequence.ref.name.toDartString(),
          steps: stepsDart);

      sequencesDart.add(sequenceDart);
    }

    return s_api.Sequences(sequences: sequencesDart);
  }

  late VoidFunctionC connectKeysight;
  late VoidFunctionC disconnectKeysight;
  late CreateBackendC _createBackend;
  late VoidFunctionC _runService;
  late SequencesC _getSequences;

  bool keysightConnectionStatus = false;
}

KeysightCAPI? keysightCAPI;

//void functions
typedef VoidFunctionFFI = ffi.Void Function();
typedef VoidFunctionC = void Function();

//get sequences function
typedef SequencesFFI = Sequences Function();
typedef SequencesC = Sequences Function();

//create backend function
typedef CreateBackendFFI = ffi.Void Function(ffi.Int64 connectionStatusPort);
typedef CreateBackendC = void Function(int connectionStatusPort);
