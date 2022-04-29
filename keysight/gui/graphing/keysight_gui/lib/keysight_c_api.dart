library c_api;

import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';
import 'dart:io';
import 'package:path/path.dart';

class MyStruct extends ffi.Struct {
  external ffi.Pointer<Utf8> info;
}

typedef CreateStruct = MyStruct Function();
typedef GetInfo = ffi.Pointer<Utf8> Function(ffi.Pointer<MyStruct>);

class Coordinate extends ffi.Struct {
  @ffi.Double()
  external double latitude;

  @ffi.Double()
  external double longitude;

  @ffi.Array(2)
  external ffi.Array<ffi.Uint8> joe;

  external ffi.Pointer<ffi.Int32> jay;

  @ffi.Uint32()
  external int size;

  external ffi.Pointer<ffi.Pointer<Utf8>> strings;
}

class Test extends ffi.Struct {
  @ffi.Uint32()
  external int test_type;

  @ffi.Uint32()
  external int test_action;

  @ffi.Double()
  external double value;

  @ffi.Uint32()
  external int time_type;

  @ffi.Uint32()
  external int time_limit;
}

class Step extends ffi.Struct {
  @ffi.Uint32()
  external int mode;

  @ffi.Uint32()
  external int seconds;

  @ffi.Double()
  external double current;

  @ffi.Double()
  external double voltage;

  external ffi.Pointer<ffi.Pointer<Test>> tests;

  @ffi.Uint32()
  external int tests_size;
}

class Sequence extends ffi.Struct {
  external ffi.Pointer<Utf8> name;
  external ffi.Pointer<Utf8> serial;
  external ffi.Pointer<Utf8> comments;

  external ffi.Pointer<ffi.Pointer<Step>> steps;

  @ffi.Uint32()
  external int steps_size;
}

class Sequences extends ffi.Struct {
  external ffi.Pointer<ffi.Pointer<Sequence>> sequences;

  @ffi.Uint32()
  external int size;
}

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

    loadProfile = lib
        .lookup<ffi.NativeFunction<LoadProfileFFI>>("load_profile")
        .asFunction();

    startSequence = lib
        .lookup<ffi.NativeFunction<StartSequenceFFI>>("start_sequence")
        .asFunction();

    connectKeysight = lib
        .lookup<ffi.NativeFunction<VoidFunctionFFI>>("connect_keysight")
        .asFunction();

    disconnectKeysight = lib
        .lookup<ffi.NativeFunction<VoidFunctionFFI>>("disconnect_keysight")
        .asFunction();

    clearCells = lib
        .lookup<ffi.NativeFunction<VoidFunctionFFI>>("clear_cells")
        .asFunction();

    selectCell = lib
        .lookup<ffi.NativeFunction<SelectCellFFI>>("select_cell")
        .asFunction();

    ReceivePort loadSequencesPort = ReceivePort()
      ..listen((data) {
        print("seq received $data");
      });

    int loadSequencesNativePort = loadSequencesPort.sendPort.nativePort;

    ReceivePort loadedProfilesPort = ReceivePort()
      ..listen((data) {
        print("seq received $data");
        tempLoadedProfiles.add(data);

        if (tempLoadedProfiles.length == 8) {
          loadedProfiles = List.from(tempLoadedProfiles);
          tempLoadedProfiles.clear();

          notifyListeners();
        }
      });

    int loadProfilesNativePort = loadedProfilesPort.sendPort.nativePort;

    ReceivePort profileStatusesPort = ReceivePort()
      ..listen((data) {
        profilesStatuses = List<int>.from(data);

        notifyListeners();
      });

    int profileStatusesNativePort = profileStatusesPort.sendPort.nativePort;

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

    getSequences = lib
        .lookup<ffi.NativeFunction<SequencesFFI>>("get_sequences")
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
        loadProfilesNativePort,
        profileStatusesNativePort);
    _runService();

    final sequences = getSequences();
    for (int i = 0; i < sequences.size; i++) {
      final sequenceInfo = List<dynamic>.empty(growable: true);
      final sequence =
          sequences.sequences.elementAt(i).cast<ffi.Pointer<Sequence>>().value;

      final name = sequence.ref.name.toDartString();
      final serial = sequence.ref.serial.toDartString();
      final comments = sequence.ref.comments.toDartString();
      print(
          "sequence $i: name: $name, serial: $serial, comments: $comments, steps size: ${sequence.ref.steps_size}");

      sequenceInfo.add(name);
      sequenceInfo.add(serial);
      sequenceInfo.add(comments);

      final sequenceSteps = List<dynamic>.empty(growable: true);

      for (int k = 0; k < sequence.ref.steps_size; k++) {
        final steps = List<dynamic>.empty(growable: true);
        final step =
            sequence.ref.steps.elementAt(k).cast<ffi.Pointer<Step>>().value;
        final mode = step.ref.mode;
        final seconds = step.ref.seconds;
        final current = step.ref.current;
        final voltage = step.ref.voltage;

        steps.add(mode);
        steps.add(seconds);
        steps.add(current);
        steps.add(voltage);

        final stepTests = List<dynamic>.empty(growable: true);

        print(
            "step $k:, mode: $mode, seconds: $seconds, current: $current, voltage: $voltage");

        for (int j = 0; j < step.ref.tests_size; j++) {
          final tests = List<dynamic>.empty(growable: true);
          final test =
              step.ref.tests.elementAt(j).cast<ffi.Pointer<Test>>().value;
          final test_type = test.ref.test_type;
          final test_action = test.ref.test_action;
          final value = test.ref.value;
          final time_type = test.ref.time_type;
          final time_limit = test.ref.time_limit;

          tests.add(test_type);
          tests.add(test_action);
          tests.add(value);
          tests.add(time_type);
          tests.add(time_limit);

          print(
              "test $j:, test type: $test_type, test action: $test_action, value: $value, time type: $time_type, time limit: $time_limit");

          stepTests.add(tests);
          malloc.free(test);
        }

        if (step.ref.tests_size > 0) {
          malloc.free(step.ref.tests);
        }

        malloc.free(step);

        steps.add(stepTests);
        sequenceSteps.add(steps);
      }

      sequenceInfo.add(sequenceSteps);

      if (sequence.ref.steps_size > 0) {
        malloc.free(sequence.ref.steps);
      }

      addSavedSequence(sequence.ref.name.toDartString());

      malloc.free(sequence.ref.name);
      malloc.free(sequence.ref.serial);
      malloc.free(sequence.ref.comments);
      malloc.free(sequence);

      loadedSequences.add(sequenceInfo);
    }

    if (sequences.size > 0) {
      malloc.free(sequences.sequences);
    }
  }

  List<dynamic> loadedSequences = List<dynamic>.empty(growable: true);
  List<dynamic> get getLoadedSequences => loadedSequences;

  List<String> tempLoadedProfiles = List<String>.empty(growable: true);
  List<String> loadedProfiles = List<String>.filled(8, "");
  List<int> profilesStatuses = List<int>.filled(8, 0);

  final List<bool> sequencesStarted = List.generate(8, (index) => false);

  final List<List<int>> cellsSelected =
      List.generate(8, (index) => List<int>.filled(32, -1));

  List<bool> cardsActive = List.from(cardsActiveDefault);

  List<String> savedSequences = List<String>.empty(growable: true);

  void addSavedSequence(String name) {
    for (int i = 0; i < savedSequences.length; i++) {
      if (savedSequences.elementAt(i).compareTo(name) == 0) {
        return;
      }
    }

    savedSequences = List.from(savedSequences)..add(name);
    notifyListeners();
  }

  void deleteSavedSeqeunce(String name) {
    for (int i = 0; i < savedSequences.length; i++) {
      if (savedSequences.elementAt(i).compareTo(name) == 0) {
        savedSequences = List.from(savedSequences)..removeAt(i);
        notifyListeners();
        return;
      }
    }
  }

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

  void setSequenceStarted(int index, int slot, bool value) {
    if (index < sequencesStarted.length) {
      sequencesStarted[index] = value;

      print("set seq started");
      clearCells();

      for (int i = 0; i < cellsSelected.length; i++) {
        List<int> inners = cellsSelected.elementAt(i);
        for (int k = 0; k < inners.length; k++) {
          int value = inners.elementAt(k);
          if (value == index) {
            //we have a winner
            int mod = (i + 1) * 1000;
            int card = k + 1;
            selectCell(mod + card);
          }
        }
      }

      if (value) {
        startSequence(slot);
      }

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
  late LoadProfileC loadProfile;
  late StartSequenceC startSequence;
  late VoidFunctionC connectKeysight;
  late VoidFunctionC disconnectKeysight;
  late SequencesC getSequences;
  late SelectCellC selectCell;
  late VoidFunctionC clearCells;

  static const String _libraryName = 'lib/libkeysight_backend.so';
}

KeysightCAPI? keysightCAPI;

//FFI signature types
typedef VoidFunctionFFI = ffi.Void Function();
typedef VoidFunctionC = void Function();

//FFI get sequence
typedef SequencesFFI = Sequences Function();
typedef SequencesC = Sequences Function();

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
    ffi.Int64 keysightUint16Port,
    ffi.Int64 loadedProfilesPort,
    ffi.Int64 profileStatusesPort);

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
    int keysightUint16Port,
    int loadedProfilesPort,
    int profileStatusesPort);

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

typedef LoadProfileFFI = ffi.Void Function(
    ffi.Pointer<Utf8> name, ffi.Uint32 slot);
typedef LoadProfileC = void Function(ffi.Pointer<Utf8> name, int slot);

typedef StartSequenceFFI = ffi.Void Function(ffi.Uint32 slot);
typedef StartSequenceC = void Function(int slot);

typedef SelectCellFFI = ffi.Void Function(ffi.Uint32 cell);
typedef SelectCellC = void Function(int cell);

final List<bool> cardsActiveDefault = List<bool>.filled(8, false);
final List<List<String>> cellsDefaultNan =
    List.generate(8, (i) => List.generate(32, (k) => "NaN"));
final List<List<String>> cellsDefaultNa =
    List.generate(8, (i) => List.generate(32, (k) => "N/A"));
