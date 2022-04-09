import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keysight_gui/screens/profile_sequence/add_sequence_step_widget.dart';
import 'package:keysight_gui/screens/profile_sequence/add_sequence_test_widget.dart';
import 'package:keysight_gui/screens/profile_sequence/sequence_list_view.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:keysight_gui/screens/profile_sequence/sequence_step_table.dart';
import 'package:keysight_gui/home_page.dart';
import 'package:keysight_gui/router_utility.dart';

class ProfileSequenceWidget extends HookWidget {
  late ValueNotifier<List<String>> sequenceList;
  late ValueNotifier<List<bool>> sequenceSaveList;
  late ValueNotifier<List<String>> sequenceTextList;
  late ValueNotifier<List<String>> cellTextList;
  late ValueNotifier<List<String>> commentsTextList;

  late TextEditingController sequenceTextController;
  late TextEditingController cellTextController;
  late TextEditingController commentsTextController;

  late ValueNotifier<int> selectedSequence;
  late ValueNotifier<bool> sequenceTextError;

  late ValueNotifier<List<List<dynamic>>> table;
  late ValueNotifier<int> dataTableSelectedIndex;

  void addNewSequence() {
    sequenceList.value = List.from(sequenceList.value)..add("New Profile");
    sequenceSaveList.value = List.from(sequenceSaveList.value)..add(false);
    sequenceTextList.value = List.from(sequenceTextList.value)..add("");
    cellTextList.value = List.from(cellTextList.value)..add("");
    commentsTextList.value = List.from(commentsTextList.value)..add("");

    selectedSequence.value = sequenceList.value.length - 1;

    refreshSequencePage();
  }

  void deleteSequence(int index) {
    int length = sequenceList.value.length;
    sequenceList.value = List.from(sequenceList.value)..removeAt(index);
    sequenceSaveList.value = List.from(sequenceSaveList.value)..removeAt(index);
    sequenceTextList.value = List.from(sequenceTextList.value)..removeAt(index);
    cellTextList.value = List.from(cellTextList.value)..removeAt(index);
    commentsTextList.value = List.from(commentsTextList.value)..removeAt(index);

    //just goto last index if we're deleting last index
    if (index == (length - 1)) {
      selectedSequence.value = sequenceList.value.length - 1;
    }

    //never want the list to be completey empty
    if (sequenceList.value.isEmpty) addNewSequence();

    refreshSequencePage();
  }

  void saveSequence(int index) {
    if (sequenceTextController.text.isEmpty) {
      sequenceTextError.value = true;
      return;
    } else if (sequenceTextError.value) {
      sequenceTextError.value = false;
    }

    //we made it to a save
    sequenceSaveList.value = List.from(sequenceSaveList.value)..[index] = true;
    sequenceList.value = List.from(sequenceList.value)
      ..[index] = sequenceTextController.text;
    sequenceTextList.value = List.from(sequenceTextList.value)
      ..[index] = sequenceTextController.text;
    cellTextList.value = List.from(cellTextList.value)
      ..[index] = cellTextController.text;
    commentsTextList.value = List.from(commentsTextList.value)
      ..[index] = commentsTextController.text;

    refreshSequencePage();
  }

  void refreshSequencePage() {
    sequenceTextError.value = false;

    sequenceTextController.text =
        sequenceTextList.value.elementAt(selectedSequence.value);
    cellTextController.text =
        cellTextList.value.elementAt(selectedSequence.value);
    commentsTextController.text =
        commentsTextList.value.elementAt(selectedSequence.value);
  }

  void setSequenceIndex(int index) {
    selectedSequence.value = index;
    refreshSequencePage();
  }

  void addTableStep(List<dynamic> step) {
    table.value = List.from(table.value)..add(step);
  }

  void addTableTest(List<dynamic> test) {
    table.value = List.from(table.value);

    List<int> indexes = List.filled(2, 0, growable: true);
    indexes = getTableIndexes(dataTableSelectedIndex.value);

    table.value.elementAt(indexes.elementAt(0)).elementAt(4).add(test);
  }

  List<int> getTableIndexes(int index) {
    List<int> result = List.filled(2, 0, growable: false);

    int mainIndex = 0;
    int secondIndex = -1;
    int totalIndex = 0;
    bool nestedBreak = false;

    for (var element in table.value) {
      secondIndex = -1;

      if (totalIndex == index) {
        break;
      }

      for (var second in element.elementAt(4)) {
        secondIndex++;
        totalIndex++;
        if (totalIndex == index) {
          nestedBreak = true;
          break;
        }
      }

      if (nestedBreak) break;
      mainIndex++;
      totalIndex++;
    }

    result[0] = mainIndex;
    result[1] = secondIndex;

    return result;
  }

  bool moveUpPossible() {
    bool result = false;

    List<int> mapping = getTableIndexes(dataTableSelectedIndex.value);

    if (mapping.elementAt(1) >= 0) {
      result = false;
    } else if (dataTableSelectedIndex.value <= 0) {
      result = false;
    } else {
      result = true;
    }

    return result;
  }

  bool moveDownPossible() {
    bool result = false;

    List<int> mapping = getTableIndexes(dataTableSelectedIndex.value);

    if (dataTableSelectedIndex.value < 0) {
      result = false;
    } else if (mapping.elementAt(1) >= 0) {
      result = false;
    } else if (mapping.elementAt(0) < table.value.length - 1) {
      result = true;
    } else {
      result = false;
    }

    return result;
  }

  void deleteStep() {
    List<int> mapping = getTableIndexes(dataTableSelectedIndex.value);

    if (mapping.elementAt(1) >= 0) {
      table.value = List.from(table.value)
        ..elementAt(mapping.elementAt(0))
            .elementAt(4)
            .removeAt(mapping.elementAt(1));
    } else {
      table.value = List.from(table.value)..removeAt(mapping.elementAt(0));
    }
  }

  void moveUp() {
    List<int> mapping = getTableIndexes(dataTableSelectedIndex.value);

    if (mapping.elementAt(1) < 0) {
      table.value = List.from(table.value);
      dynamic removedItem = table.value.elementAt(mapping.elementAt(0));
      table.value.removeAt(mapping.elementAt(0));
      table.value.insert(mapping.elementAt(0) - 1, removedItem);
    }
  }

  void moveDown() {
    List<int> mapping = getTableIndexes(dataTableSelectedIndex.value);

    if (mapping.elementAt(1) < 0) {
      table.value = List.from(table.value);
      dynamic removedItem = table.value.elementAt(mapping.elementAt(0));
      table.value.removeAt(mapping.elementAt(0));
      table.value.insert(mapping.elementAt(0) + 1, removedItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    sequenceList = useState(<String>["New Profile"]);
    selectedSequence = useState<int>(sequenceList.value.length - 1);
    sequenceTextList = useState(<String>[""]);
    cellTextList = useState(<String>[""]);
    commentsTextList = useState(<String>[""]);

    sequenceTextController = useTextEditingController();
    cellTextController = useTextEditingController();
    commentsTextController = useTextEditingController();

    sequenceTextError = useState<bool>(false);
    sequenceSaveList = useState(<bool>[false]);

    dataTableSelectedIndex = useState(-1);

    table = useState(<List<dynamic>>[]);

    return Container(
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 12.0, top: 12.0, bottom: 12.0),
              child: Column(
                children: [
                  Text(
                    "Save, Create or Delete Profile Sequences:",
                    style: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () =>
                                saveSequence(selectedSequence.value),
                            child: Text(
                              "Save",
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.green,
                            ),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => addNewSequence(),
                            child: Text("New"),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () =>
                                deleteSequence(selectedSequence.value),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.red,
                            ),
                            child: Text("Delete"),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Expanded(
                    child: SequenceListView(
                      selectedSequence: (value) => setSequenceIndex(value),
                      selectedIndex: selectedSequence.value,
                      sequenceList: sequenceList.value,
                      sequenceItalic: sequenceSaveList.value,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              height: double.infinity,
              color: Colors.grey.shade900,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: sequenceTextController,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              border: OutlineInputBorder(),
                              hintText: "Enter Name of Profile Sequence",
                              hintStyle: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontStyle: FontStyle.italic),
                              errorText: sequenceTextError.value
                                  ? "A Name of a Sequence Must be Given"
                                  : null,
                              filled: true,
                              fillColor: Colors.grey.shade800,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp("[0-9a-zA-Z_ ]"))
                            ],
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: cellTextController,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              border: OutlineInputBorder(),
                              hintText: "Enter Serial Number of Cell",
                              hintStyle: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontStyle: FontStyle.italic),
                              filled: true,
                              fillColor: Colors.grey.shade800,
                            ),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    TextField(
                      controller: commentsTextController,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        border: OutlineInputBorder(),
                        hintText: "Include any additional comments here.",
                        hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontStyle: FontStyle.italic),
                        filled: true,
                        fillColor: Colors.grey.shade800,
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    SequenceStepTable(
                      table: table.value,
                      onIndexChanged: (p0) {
                        dataTableSelectedIndex.value = p0;
                      },
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () => RouterUtility.routerUtility(
                              context,
                              AddSequenceStepWidget(
                                onSave: (int mode, int seconds, double current,
                                        double voltage) =>
                                    addTableStep(<dynamic>[
                                  mode,
                                  seconds,
                                  current,
                                  voltage,
                                  <dynamic>[]
                                ]),
                              )),
                          child: Text("Add Step"),
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        ElevatedButton(
                          onPressed: (dataTableSelectedIndex.value == -1)
                              ? null
                              : () => RouterUtility.routerUtility(context,
                                      AddSequenceTestWidget(
                                    onSave: (int testType,
                                        int testAction,
                                        double value,
                                        int timeType,
                                        int timeLimit) {
                                      addTableTest(<dynamic>[
                                        testType,
                                        testAction,
                                        value,
                                        timeType,
                                        timeLimit
                                      ]);
                                    },
                                  )),
                          child: Text("Add Test"),
                          style: ElevatedButton.styleFrom(
                            onSurface: Colors.grey,
                          ),
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        ElevatedButton(
                          onPressed: null,
                          child: Text("Edit"),
                          style: ElevatedButton.styleFrom(
                            onSurface: Colors.grey,
                          ),
                        ),
                        SizedBox(
                          width: 32,
                        ),
                        ElevatedButton(
                          onPressed: !moveUpPossible()
                              ? null
                              : () {
                                  moveUp();
                                },
                          child: Text("Move Up"),
                          style: ElevatedButton.styleFrom(
                            onSurface: Colors.grey,
                          ),
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        ElevatedButton(
                          onPressed: !moveDownPossible()
                              ? null
                              : () {
                                  moveDown();
                                },
                          child: Text("Move Down"),
                          style: ElevatedButton.styleFrom(
                            onSurface: Colors.grey,
                          ),
                        ),
                        SizedBox(
                          width: 32,
                        ),
                        ElevatedButton(
                          onPressed: (dataTableSelectedIndex.value == -1)
                              ? null
                              : () {
                                  print("does this happen?");
                                  deleteStep();
                                },
                          child: Text("Delete Step"),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.red,
                            onSurface: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
