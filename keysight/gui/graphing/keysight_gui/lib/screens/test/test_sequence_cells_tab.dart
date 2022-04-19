import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:keysight_gui/keysight_c_api.dart';

class TestSequenceCellsTab extends HookWidget {
  TestSequenceCellsTab(
      {Key? key,
      required this.canStartSequence,
      required this.sequenceStarted,
      required this.sequenceNumber})
      : super(key: key);

  final void Function(bool value, List<List<bool>> cells) canStartSequence;

  late ValueNotifier<List<List<bool>>> checkCount;
  final bool sequenceStarted;
  final int sequenceNumber;

  bool isOneBoxChecked() {
    for (var i in checkCount.value) {
      for (var k in i) {
        if (k == true) return true;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final cardsActive = context.select((KeysightCAPI k) => k.cardsActive);
    final cellsSelected = context.select((KeysightCAPI k) => k.cellsSelected);
    final c_api = Provider.of<KeysightCAPI>(context, listen: false);

    checkCount = useState(
        List<List<bool>>.generate(8, (index) => List<bool>.filled(32, false)));

    return ListView.builder(
        controller: ScrollController(),
        itemCount: 32,
        itemBuilder: (BuildContext context, int c_idx) {
          return Row(
            children: List.generate(
                8,
                (l_idx) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: TestCellsCheckboxWidget(
                          cellNumber: c_idx,
                          moduleNumber: l_idx,
                          moduleActive: cardsActive.elementAt(l_idx),
                          sequenceStarted: sequenceStarted,
                          cellActiveInSequence:
                              cellsSelected.elementAt(l_idx).elementAt(c_idx),
                          sequenceNumber: sequenceNumber,
                          onChanged: (bool value) {
                            checkCount.value[l_idx][c_idx] = value;
                            canStartSequence(
                                isOneBoxChecked(), checkCount.value);
                            //c_api.setCellSequenceStarted(
                            //  l_idx, c_idx, sequenceNumber, value);
                          },
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
}

class TestCellsCheckboxWidget extends HookWidget {
  TestCellsCheckboxWidget({
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
  late ValueNotifier<bool> checked;
  late KeysightCAPI c_api;

  final void Function(bool value) onChanged;

  String getCellString(int module, int index) {
    String res = "";

    module += 1;
    index += 1;

    res += module.toString();

    if (index < 10)
      res += "00";
    else
      res += "0";

    res += index.toString();

    return res;
  }

  StatusCellCheckbox getMode() {
    //0 = inactive
    //1 = active
    //2 = running already
    if (sequenceNumber == 0) {
      //print(
      //  "seq $sequenceNumber mod $moduleNumber, cell $cellNumber active $cellActiveInSequence");
      //print(
      //  "${c_api.cellsSelected.elementAt(moduleNumber).elementAt(cellNumber)}");
    }

    /*if (sequenceStarted && cellActiveInSequence == sequenceNumber) {
      return StatusCellCheckbox.running; //can't select this but it's checked
    } else if (!moduleActive || sequenceStarted) {
      checked.value = false;
      return StatusCellCheckbox.inactive; //module is not active
    } else {
      return StatusCellCheckbox.active;
    }*/

    return StatusCellCheckbox.active;
  }

  Color? getBoxDecorationColor() {
    switch (getMode()) {
      case StatusCellCheckbox.running:
      case StatusCellCheckbox.active:
        return Colors.grey.shade800;
      case StatusCellCheckbox.inactive:
        return Colors.grey.shade900;
      default:
        return Colors.grey.shade800;
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
      default:
        return Colors.white;
    }
  }

  bool getModeCheckable() {
    switch (getMode()) {
      case StatusCellCheckbox.running:
        return false;
      case StatusCellCheckbox.active:
        return true;
      case StatusCellCheckbox.inactive:
        return false;
      default:
        return false;
    }
  }

  void checkedChange(bool flag) {
    if (checked.value != flag) {
      checked.value = flag;
      onChanged(flag);
    }
  }

  @override
  Widget build(BuildContext context) {
    checked = useState(false);

    c_api = Provider.of<KeysightCAPI>(context, listen: false);

    return Container(
      decoration: BoxDecoration(
        color: getBoxDecorationColor(),
      ),
      child: CheckboxListTile(
        title: Text("Cell ${getCellString(moduleNumber, cellNumber)}",
            style: TextStyle(
              color: getTextColor(),
            )),
        value: checked.value,
        onChanged: !getModeCheckable()
            ? null
            : (newValue) {
                print("value changed? $newValue");
                c_api.setCellSequenceStarted(moduleNumber, cellNumber,
                    sequenceNumber, newValue ?? false);
                checked.value = newValue ?? false;
                onChanged(newValue ?? false);
              },
        controlAffinity:
            ListTileControlAffinity.leading, //  <-- leading Checkbox
      ),
    );
  }
}
