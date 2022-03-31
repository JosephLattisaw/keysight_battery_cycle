import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keysight_gui/screens/profile_sequence/sequence_list_view.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:keysight_gui/screens/profile_sequence/sequence_step_table.dart';

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

    final dataTableSelectedIndex = useState(-1);

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
                    SequenceStepTable(),
                    SizedBox(
                      height: 12,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          child: Text("Add Step"),
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        ElevatedButton(
                          onPressed: null,
                          child: Text("Add Test",
                              style: TextStyle(color: Colors.grey)),
                          style: ElevatedButton.styleFrom(
                            onSurface: Colors.grey,
                          ),
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          child: Text("Edit"),
                        ),
                        SizedBox(
                          width: 32,
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          child: Text("Move Up"),
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          child: Text("Move Down"),
                        ),
                        SizedBox(
                          width: 32,
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          child: Text("Delete Step"),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.red,
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
