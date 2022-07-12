import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:keysight_gui/keysight_c_api.dart';

class TestSequenceCellsTab extends HookWidget {
  const TestSequenceCellsTab(
      {Key? key,
      required this.canStartSequence,
      required this.sequenceStarted,
      required this.sequenceNumber})
      : super(key: key);

  final void Function(bool value, List<List<bool>> cells) canStartSequence;
  final bool sequenceStarted;
  final int sequenceNumber;

  @override
  Widget build(BuildContext context) {
    final cardsActive = context.select((KeysightCAPI k) => k.cardsActive);
    final cellsSelected = context.select((KeysightCAPI k) => k.cellsSelected);

    final checkCount = useState(
        List<List<bool>>.generate(8, (index) => List<bool>.filled(32, false)));

    bool isOneBoxChecked() {
      for (var i in checkCount.value) {
        for (var k in i) {
          if (k == true) return true;
        }
      }

      return false;
    }

    bool isCellSelectedButNotHere(int module, int cell, int sequenceNumber) {
      int value = cellsSelected.elementAt(module).elementAt(cell);
      if (value != sequenceNumber && value != -1) {
        return true;
      } else {
        return false;
      }
    }

    return ListView.builder(
        controller: ScrollController(),
        itemCount: 32,
        itemBuilder: (BuildContext context, int cIdx) {
          return Row(
            children: List.generate(
                8,
                (lIdx) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: Tooltip(
                          message: isCellSelectedButNotHere(
                                  lIdx, cIdx, sequenceNumber)
                              ? "Active on Test ${cellsSelected.elementAt(lIdx).elementAt(cIdx) + 1}"
                              : "",
                          child: TestCellsCheckboxWidget(
                            cellNumber: cIdx,
                            moduleNumber: lIdx,
                            moduleActive: cardsActive.elementAt(lIdx),
                            sequenceStarted: sequenceStarted,
                            cellActiveInSequence:
                                cellsSelected.elementAt(lIdx).elementAt(cIdx),
                            sequenceNumber: sequenceNumber,
                            onChanged: (bool value) {
                              checkCount.value[lIdx][cIdx] = value;
                              canStartSequence(
                                  isOneBoxChecked(), checkCount.value);
                            },
                          ),
                        ),
                      ),
                    )),
          );
        });
  }
}

enum StatusCellCheckbox {
  inactive,
  active,
  running,
  runningInAnotherSequence,
}

class TestCellsCheckboxWidget extends HookWidget {
  const TestCellsCheckboxWidget({
    Key? key,
    required this.moduleNumber,
    required this.cellNumber,
    required this.moduleActive,
    required this.sequenceStarted,
    required this.cellActiveInSequence,
    required this.onChanged,
    required this.sequenceNumber,
  }) : super(key: key);

  final int cellNumber;
  final int moduleNumber;
  final bool moduleActive;
  final bool sequenceStarted;
  final int cellActiveInSequence;
  final int sequenceNumber;

  final void Function(bool value) onChanged;

  String getCellString(int module, int index) {
    String res = "";

    module += 1;
    index += 1;

    res += module.toString();

    if (index < 10) {
      res += "00";
    } else {
      res += "0";
    }

    res += index.toString();

    return res;
  }

  @override
  Widget build(BuildContext context) {
    final oldChecked = useState(false);
    final checked = useState(cellActiveInSequence == sequenceNumber);

    if (checked.value != oldChecked.value) {
      onChanged(checked.value);
    }

    final cApi = Provider.of<KeysightCAPI>(context, listen: false);

    StatusCellCheckbox getMode() {
      if (sequenceStarted) {
        if (cellActiveInSequence == sequenceNumber) {
          return StatusCellCheckbox.running;
        } else if (cellActiveInSequence == -1) {
          return StatusCellCheckbox.inactive;
        } else {
          return StatusCellCheckbox.runningInAnotherSequence;
        }
      } else {
        if (!moduleActive) {
          return StatusCellCheckbox.inactive;
        } else if (cellActiveInSequence == -1) {
          return StatusCellCheckbox.active;
        } else if (cellActiveInSequence != sequenceNumber) {
          return StatusCellCheckbox.runningInAnotherSequence;
        } else {
          return StatusCellCheckbox.active;
        }
      }
    }

    bool getModeCheckable() {
      switch (getMode()) {
        case StatusCellCheckbox.running:
        case StatusCellCheckbox.inactive:
        case StatusCellCheckbox.runningInAnotherSequence:
          return false;
        case StatusCellCheckbox.active:
          return true;
        default:
          return false;
      }
    }

    Color? getTextColor() {
      switch (getMode()) {
        case StatusCellCheckbox.running:
          return Colors.green;
        case StatusCellCheckbox.active:
          return Colors.white;
        case StatusCellCheckbox.inactive:
          return Colors.black;
        case StatusCellCheckbox.runningInAnotherSequence:
          return Colors.blue.shade900;
        default:
          return Colors.white;
      }
    }

    Color? getBoxDecorationColor() {
      switch (getMode()) {
        case StatusCellCheckbox.running:
        case StatusCellCheckbox.active:
          return Colors.grey.shade800;
        case StatusCellCheckbox.inactive:
        case StatusCellCheckbox.runningInAnotherSequence:
          return Colors.grey.shade900;
        default:
          return Colors.grey.shade800;
      }
    }

    bool isSerialNumberEditable() {
      return getModeCheckable() && checked.value;
    }

    final serialNumberController = useTextEditingController(
        text: cApi.serialNumbersMap
            .elementAt(moduleNumber)
            .elementAt(cellNumber));

    return Container(
      decoration: BoxDecoration(
        color: getBoxDecorationColor(),
      ),
      child: Column(
        children: [
          CheckboxListTile(
            title: Text("Cell ${getCellString(moduleNumber, cellNumber)}",
                style: TextStyle(
                  color: getTextColor(),
                )),
            value: checked.value,
            onChanged: !getModeCheckable()
                ? null
                : (newValue) {
                    cApi.setCellSequenceStarted(moduleNumber, cellNumber,
                        sequenceNumber, newValue ?? false);
                    onChanged(newValue ?? false);
                    checked.value = newValue ?? false;
                    oldChecked.value = checked.value;
                  },
            controlAffinity:
                ListTileControlAffinity.leading, //  <-- leading Checkbox
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              enabled: isSerialNumberEditable(),
              controller: serialNumberController,
              onChanged: (String? text) {
                cApi.serialNumbersMap[moduleNumber][cellNumber] = text ?? "";
              },
              decoration: InputDecoration(
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                border: const OutlineInputBorder(),
                hintStyle: TextStyle(
                    color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                filled: true,
                fillColor: Colors.grey.shade800,
                labelText: "Serial Number",
                labelStyle: isSerialNumberEditable() ||
                        serialNumberController.text.isNotEmpty
                    ? TextStyle(color: Colors.blueGrey.shade300)
                    : null,
              ),
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          )
        ],
      ),
    );
  }
}
