library c_api;

import 'dart:isolate';

import 'package:flutter/material.dart';
import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';
import 'dart:io';
import 'package:path/path.dart';

class KeysightCAPI extends ChangeNotifier {
  KeysightCAPI() {
    print("resolved exec path1: ${Platform.resolvedExecutable}");
    keysightCAPI = this;

    File exeFile = File(Platform.resolvedExecutable);
    String libPath = "${dirname(exeFile.path)}/$_libraryName";

    print("attempting to open library name: $libPath");
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

    startSaveSequence = lib
        .lookup<ffi.NativeFunction<StartSaveSequenceFFI>>("start_save_sequence")
        .asFunction();

    addSaveSequenceStep = lib
        .lookup<ffi.NativeFunction<AddSaveSequenceStepFFI>>(
            "add_save_sequence_step")
        .asFunction();

    addSaveSequenceTest = lib
        .lookup<ffi.NativeFunction<AddSaveSequenceTestFFI>>(
            "add_save_sequence_test")
        .asFunction();

    finishSaveSequence = lib
        .lookup<ffi.NativeFunction<VoidFunctionFFI>>("finish_save_sequence")
        .asFunction();

    _runService = lib
        .lookup<ffi.NativeFunction<VoidFunctionFFI>>("run_service")
        .asFunction();

    sequenceRemove = lib
        .lookup<ffi.NativeFunction<SequenceRemoveFFI>>("sequence_remove")
        .asFunction();

    ReceivePort loadSequencesPort = ReceivePort()
      ..listen((data) {
        print("seq received $data");
      });

    int loadSequencesNativePort = loadSequencesPort.sendPort.nativePort;

    ReceivePort finishLoadSequencesPort = ReceivePort()
      ..listen((data) {
        print("finished seq received $data");
      });

    int finishLoadSequencesNativePort =
        finishLoadSequencesPort.sendPort.nativePort;

    ReceivePort loadStepsPort = ReceivePort()
      ..listen((data) {
        print("received $data");
      });

    int loadStepsNativePort = loadStepsPort.sendPort.nativePort;

    ReceivePort loadTestsPort = ReceivePort()
      ..listen((data) {
        print("received $data");
      });

    int loadTestsNativePort = loadTestsPort.sendPort.nativePort;

    loadAllSequences = lib
        .lookup<ffi.NativeFunction<VoidFunctionFFI>>("load_all_sequences")
        .asFunction();

    _createBackend(1, loadSequencesNativePort, finishLoadSequencesNativePort,
        loadStepsNativePort, loadTestsNativePort);
    _runService();
  }

  final List<bool> sequencesStarted = List.generate(8, (index) => false);

  final List<List<int>> cellsSelected =
      List.generate(8, (index) => List<int>.filled(32, -1));

  final List<bool> cardsActive = List.generate(8, (index) {
    if (index < 3) {
      return true;
    } else {
      return false;
    }
  });

  final List<List<String>> cellNames = List.generate(
      8,
      (i) => List.generate(32, (k) {
            String moduleNumber = (i + 1).toString();
            String betweenNumber = "0";
            if ((k + 1) < 10) {
              betweenNumber = "00";
            }
            String endNumber = (k + 1).toString();

            return moduleNumber + betweenNumber + endNumber;
          }));

  final List<List<double>> voltageValues =
      List.generate(8, (i) => List.generate(32, (k) => 0.0));

  final List<List<double>> currentValues =
      List.generate(8, (i) => List.generate(32, (k) => 0.0));

  final List<List<double>> capacityAmpHrs =
      List.generate(8, (i) => List.generate(32, (k) => 0.0));
  final List<List<double>> capacityWattHrs =
      List.generate(8, (i) => List.generate(32, (k) => 0.0));

  void setSequenceStarted(int index, bool value) {
    if (index < sequencesStarted.length) {
      sequencesStarted[index] = value;
      notifyListeners();
    }
  }

  void setCellSequenceStarted(
      int module, int index, int sequenceNumber, bool value) {
    if (module < cellsSelected.length) {
      if (index < cellsSelected.elementAt(module).length) {
        if (value && cellsSelected[module][index] == -1) {
          cellsSelected[module][index] = sequenceNumber;
          notifyListeners();
        } else if (!value && cellsSelected[module][index] == sequenceNumber) {
          cellsSelected[module][index] = -1;
          notifyListeners();
        }
      } else {
        assert(false);
      }
    } else {
      assert(false);
    }
  }

  late StartSaveSequenceC startSaveSequence;
  late AddSaveSequenceStepC addSaveSequenceStep;
  late AddSaveSequenceTestC addSaveSequenceTest;
  late VoidFunctionC finishSaveSequence;
  late CreateBackendC _createBackend;
  late VoidFunctionC _runService;
  late SequenceRemoveC sequenceRemove;
  late VoidFunctionC loadAllSequences;

  static const String _libraryName = 'lib/libkeysight_backend.so';
}

KeysightCAPI? keysightCAPI;

//FFI signature types
typedef VoidFunctionFFI = ffi.Void Function();
typedef VoidFunctionC = void Function();

//create backend
typedef CreateBackendFFI = ffi.Void Function(
    ffi.Uint8 usingDart,
    ffi.Int64 seqPort,
    ffi.Int64 seqFinPort,
    ffi.Int64 stepsPort,
    ffi.Int64 testsPort);
typedef CreateBackendC = void Function(
    int usingDart, int seqPort, int seqFinPort, int stepsPort, int testsPort);

//start save sequence
typedef StartSaveSequenceFFI = ffi.Void Function(ffi.Pointer<Utf8> name,
    ffi.Pointer<Utf8> serialNumber, ffi.Pointer<Utf8> comments);
typedef StartSaveSequenceC = void Function(ffi.Pointer<Utf8> name,
    ffi.Pointer<Utf8> serialNumber, ffi.Pointer<Utf8> comments);

//add save sequence step
typedef AddSaveSequenceStepFFI = ffi.Void Function(
    ffi.Int32 mode, ffi.Int32 seconds, ffi.Double current, ffi.Double voltage);
typedef AddSaveSequenceStepC = void Function(
    int mode, int seconds, double current, double voltage);

//add save sequence test
typedef AddSaveSequenceTestFFI = ffi.Void Function(
    ffi.Int32 testType,
    ffi.Int32 testAction,
    ffi.Double value,
    ffi.Int32 timeType,
    ffi.Int32 timeLimit);
typedef AddSaveSequenceTestC = void Function(
    int testType, int testAction, double value, int timeType, int timeLimit);

typedef SequenceRemoveFFI = ffi.Void Function(ffi.Pointer<Utf8> name);
typedef SequenceRemoveC = void Function(ffi.Pointer<Utf8> name);
