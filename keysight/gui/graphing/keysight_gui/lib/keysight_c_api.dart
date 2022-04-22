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

    connectKeysight = lib
        .lookup<ffi.NativeFunction<VoidFunctionFFI>>("connect_keysight")
        .asFunction();

    disconnectKeysight = lib
        .lookup<ffi.NativeFunction<VoidFunctionFFI>>("disconnect_keysight")
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

    ReceivePort activeCardsPort = ReceivePort()
      ..listen((data) {
        if (data.length == 8) {
          cardsActive = List<bool>.from(List<int>.from(data)
              .cast<int>()
              .map((e) => e == 0 ? false : true));
          notifyListeners();
        }
      });

    int activeCardsNativePort = activeCardsPort.sendPort.nativePort;

    ReceivePort keysightConnectionPort = ReceivePort()
      ..listen((data) {
        print("received keysight connection status $data");
        keysightConnectionStatus = data;

        //if we got disconnected reset state
        if (!keysightConnectionStatus) {
          cardsActive = List.from(cardsActiveDefault);
          capacityAmpHrs = List.from(cellsDefaultNan);
          capacityWattHrs = List.from(cellsDefaultNan);
          voltageValues = List.from(cellsDefaultNan);
          currentValues = List.from(cellsDefaultNan);
          currentSequenceIds = List.from(cellsDefaultNa);
          currentStepIds = List.from(cellsDefaultNa);
        }

        notifyListeners();
      });

    ReceivePort keysightDoublePort = ReceivePort()
      ..listen((data) {
        if (data.length == 34) {
          int type = data.elementAt(0).toInt();
          int index = data.elementAt(1).toInt();

          List<double> dataList = List<double>.from(data)
            ..removeAt(1)
            ..removeAt(0);

          List<String> finishedData = List<String>.from(
              dataList.cast<double>().map((e) => e.toString()));

          switch (type) {
            case 0:
              capacityAmpHrs = List.from(capacityAmpHrs);
              if (index < capacityAmpHrs.length) {
                capacityAmpHrs[index] = finishedData;
              }
              break;
            case 1:
              capacityWattHrs = List.from(capacityWattHrs);
              if (index < capacityWattHrs.length) {
                capacityWattHrs[index] = finishedData;
              }
              break;
            case 2:
              voltageValues = List.from(voltageValues);
              if (index < voltageValues.length) {
                voltageValues[index] = finishedData;
              }
              break;
            case 3:
              currentValues = List.from(currentValues);
              if (index < currentValues.length) {
                currentValues[index] = finishedData;
              }
              break;
            default:
          }

          notifyListeners();
        }
      });

    int keysightDoubleNativePort = keysightDoublePort.sendPort.nativePort;

    ReceivePort cellStatePort = ReceivePort()
      ..listen((data) {
        /* if (data.length == 33) {
          int index = data.elementAt(0).toInt();

          if (index < capacityAmpHrs.length) {
            capacityAmpHrs = List.from(capacityAmpHrs);
            List<double> dataList = List<double>.from(data)..removeAt(0);
            capacityAmpHrs[index] = List<String>.from(
                dataList.cast<double>().map((e) => e.toString()));
          }
          notifyListeners();
        }*/
      });

    int cellStateNativePort = cellStatePort.sendPort.nativePort;

    ReceivePort cellStatusPort = ReceivePort()
      ..listen((data) {
        /* if (data.length == 33) {
          int index = data.elementAt(0).toInt();

          if (index < capacityAmpHrs.length) {
            capacityAmpHrs = List.from(capacityAmpHrs);
            List<double> dataList = List<double>.from(data)..removeAt(0);
            capacityAmpHrs[index] = List<String>.from(
                dataList.cast<double>().map((e) => e.toString()));
          }
          notifyListeners();
        }*/
      });

    int cellStatusNativePort = cellStatusPort.sendPort.nativePort;

    ReceivePort keysightUint16Port = ReceivePort()
      ..listen((data) {
        if (data.length == 34) {
          int type = data.elementAt(0).toInt();
          int index = data.elementAt(1).toInt();

          List<int> dataList = List<int>.from(data)
            ..removeAt(1)
            ..removeAt(0);

          List<String> finishedData =
              List<String>.from(dataList.cast<int>().map((e) => e.toString()));

          switch (type) {
            case 0:
              currentSequenceIds = List.from(currentSequenceIds);
              if (index < currentSequenceIds.length) {
                currentSequenceIds[index] = finishedData;
              }
              break;
            case 1:
              currentStepIds = List.from(currentStepIds);
              if (index < currentStepIds.length) {
                currentStepIds[index] = finishedData;
              }
              break;
            default:
          }

          notifyListeners();
        }
      });

    int keysightUint16NativePort = keysightUint16Port.sendPort.nativePort;

    int keysightConnectionNativePort =
        keysightConnectionPort.sendPort.nativePort;

    loadAllSequences = lib
        .lookup<ffi.NativeFunction<VoidFunctionFFI>>("load_all_sequences")
        .asFunction();

    _createBackend(
      1,
      loadSequencesNativePort,
      finishLoadSequencesNativePort,
      loadStepsNativePort,
      loadTestsNativePort,
      activeCardsNativePort,
      keysightConnectionNativePort,
      keysightDoubleNativePort,
      cellStateNativePort,
      cellStatusNativePort,
      keysightUint16NativePort,
    );
    _runService();
  }

  final List<bool> sequencesStarted = List.generate(8, (index) => false);

  final List<List<int>> cellsSelected =
      List.generate(8, (index) => List<int>.filled(32, -1));

  List<bool> cardsActive = List.from(cardsActiveDefault);

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

//double mapped data
  List<List<String>> voltageValues = List.from(cellsDefaultNan);
  List<List<String>> capacityAmpHrs = List.from(cellsDefaultNan);
  List<List<String>> capacityWattHrs = List.from(cellsDefaultNan);
  List<List<String>> currentValues = List.from(cellsDefaultNan);
  List<List<String>> currentSequenceIds = List.from(cellsDefaultNa);
  List<List<String>> currentStepIds = List.from(cellsDefaultNa);

  bool keysightConnectionStatus = false;

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

  List<List<int>> getCellsSelected(int sequenceNumber) {
    List<List<int>> cellsAndModules = [];
    for (int i = 0; i < cellsSelected.length; i++) {
      for (int k = 0; k < cellsSelected.elementAt(i).length; k++) {
        if (cellsSelected.elementAt(i).elementAt(k) == sequenceNumber) {
          cellsAndModules.add([i, k]);
        }
      }
    }

    return cellsAndModules;
  }

  late StartSaveSequenceC startSaveSequence;
  late AddSaveSequenceStepC addSaveSequenceStep;
  late AddSaveSequenceTestC addSaveSequenceTest;
  late VoidFunctionC finishSaveSequence;
  late CreateBackendC _createBackend;
  late VoidFunctionC _runService;
  late SequenceRemoveC sequenceRemove;
  late VoidFunctionC loadAllSequences;
  late VoidFunctionC connectKeysight;
  late VoidFunctionC disconnectKeysight;

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
    ffi.Int64 testsPort,
    ffi.Int64 activeCardsPort,
    ffi.Int64 keysightConnectionPort,
    ffi.Int64 keysightDoublePort,
    ffi.Int64 cellStatePort,
    ffi.Int64 cellStatusPort,
    ffi.Int64 keysightUint16Port);

typedef CreateBackendC = void Function(
    int usingDart,
    int seqPort,
    int seqFinPort,
    int stepsPort,
    int testsPort,
    int activeCardsPort,
    int keysightConnectionPort,
    int keysightDoublePort,
    int cellStatePort,
    int cellStatusPort,
    int keysightUint16Port);

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

final List<bool> cardsActiveDefault = List<bool>.filled(8, false);
final List<List<String>> cellsDefaultNan =
    List.generate(8, (i) => List.generate(32, (k) => "NaN"));
final List<List<String>> cellsDefaultNa =
    List.generate(8, (i) => List.generate(32, (k) => "N/A"));
