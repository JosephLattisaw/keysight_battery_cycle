import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keysight_gui/screens/profile_sequence/sequence_list_view.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

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
    sequenceList.value = List.from(sequenceList.value)..add("New Sequence");
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
    sequenceList = useState(<String>["New Sequence"]);
    selectedSequence = useState<int>(sequenceList.value.length - 1);
    sequenceTextList = useState(<String>[""]);
    cellTextList = useState(<String>[""]);
    commentsTextList = useState(<String>[""]);

    sequenceTextController = useTextEditingController();
    cellTextController = useTextEditingController();
    commentsTextController = useTextEditingController();

    sequenceTextError = useState<bool>(false);
    sequenceSaveList = useState(<bool>[false]);

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
                  Expanded(
                    child: SequenceListView(
                      selectedSequence: (value) => setSequenceIndex(value),
                      selectedIndex: selectedSequence.value,
                      sequenceList: sequenceList.value,
                      sequenceItalic: sequenceSaveList.value,
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () => addNewSequence(),
                          child: Text("New"),
                        ),
                        ElevatedButton(
                          onPressed: () =>
                              deleteSequence(selectedSequence.value),
                          child: Text("Delete"),
                        ),
                        ElevatedButton(
                          onPressed: () => saveSequence(selectedSequence.value),
                          child: Text("Save"),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              height: double.infinity,
              color: Colors.white,
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
                              border: OutlineInputBorder(),
                              hintText: "Enter Name of Sequence",
                              errorText: sequenceTextError.value
                                  ? "A Name of a Sequence Must be Given"
                                  : null,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp("[0-9a-zA-Z_ ]"))
                            ],
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: SpinBox(
                            min: 0,
                            max: 50,
                            value: 15,
                            spacing: 24,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: const EdgeInsets.only(
                                left: 0,
                                bottom: 20,
                                right: 0,
                                top: 20,
                              ),
                              hintText: "hint",
                              labelText: "C Rating (A)",
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: SpinBox(
                            min: 0,
                            max: 50,
                            value: 15,
                            spacing: 24,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: const EdgeInsets.only(
                                left: 0,
                                bottom: 20,
                                right: 0,
                                top: 20,
                              ),
                              hintText: "hint",
                              labelText: "Over Voltage (V)",
                            ),
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
                              border: OutlineInputBorder(),
                              hintText: "Enter Serial Number of Cell",
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: SpinBox(
                            min: 0,
                            max: 50,
                            value: 15,
                            spacing: 24,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: const EdgeInsets.only(
                                left: 0,
                                bottom: 20,
                                right: 0,
                                top: 20,
                              ),
                              hintText: "hint",
                              labelText: "Capacity (Ah)",
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: SpinBox(
                            min: 0,
                            max: 50,
                            value: 15,
                            spacing: 24,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: const EdgeInsets.only(
                                left: 0,
                                bottom: 20,
                                right: 0,
                                top: 20,
                              ),
                              hintText: "hint",
                              labelText: "Under Voltage (V)",
                            ),
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
                        border: OutlineInputBorder(),
                        hintText: "Include any additional comments here.",
                      ),
                    ),
                    Spacer(),
                    Text(
                      "The sequence is empty. Use Create New Step to add a step.",
                    ),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          color: Colors.black,
                          child: Column(
                            children: [
                              Text(
                                "Create New",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    ElevatedButton(
                                      child: Text("Step"),
                                      onPressed: () {},
                                    ),
                                    SizedBox(width: 8),
                                    ElevatedButton(
                                      child: Text("Test"),
                                      onPressed: () {},
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          color: Colors.black,
                          child: Column(
                            children: [
                              Text(
                                "Selection",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    ElevatedButton(
                                      child: Text("Step"),
                                      onPressed: () {},
                                    ),
                                    SizedBox(width: 8),
                                    ElevatedButton(
                                      child: Text("Step"),
                                      onPressed: () {},
                                    ),
                                    SizedBox(width: 8),
                                    ElevatedButton(
                                      child: Text("Step"),
                                      onPressed: () {},
                                    ),
                                    SizedBox(width: 8),
                                    ElevatedButton(
                                      child: Text("Step"),
                                      onPressed: () {},
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
