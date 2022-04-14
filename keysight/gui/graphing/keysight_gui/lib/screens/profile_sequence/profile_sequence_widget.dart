import 'package:ffi/src/utf8.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keysight_gui/screens/profile_sequence/add_sequence_step_widget.dart';
import 'package:keysight_gui/screens/profile_sequence/add_sequence_test_widget.dart';
import 'package:keysight_gui/screens/profile_sequence/sequence_list_view.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:keysight_gui/screens/profile_sequence/sequence_step_table.dart';
import 'package:keysight_gui/router_utility.dart';
import 'package:keysight_gui/keysight_c_api.dart';
import 'package:provider/provider.dart';

class ProfileSequenceWidget extends HookWidget {
  late ValueNotifier<List<String>> sequenceList;
  late ValueNotifier<List<bool>> sequenceSaveList;
  late ValueNotifier<List<String>> sequenceTextList;
  late ValueNotifier<List<String>> cellTextList;
  late ValueNotifier<List<String>> commentsTextList;

  late ValueNotifier<int> selectedSequence;

  late ValueNotifier<List<Widget>> sequenceWidgets;

  late PageController pageController = PageController();

  late KeysightCAPI backend;

  int totalPageCount = 1; //we start with 1 page

  void addNewSequence() {
    sequenceList.value = List.from(sequenceList.value)..add("New Profile");
    sequenceSaveList.value = List.from(sequenceSaveList.value)..add(false);
    sequenceTextList.value = List.from(sequenceTextList.value)..add("");
    cellTextList.value = List.from(cellTextList.value)..add("");
    commentsTextList.value = List.from(commentsTextList.value)..add("");

    print("add new sequence called ${sequenceList.value.length}");
    sequenceWidgets.value.add(SequenceBuilderKeepAliveClient(
      key: UniqueKey(),
      pageIndex: totalPageCount,
      currentIndex: sequenceList.value.length - 1,
    ));

    totalPageCount++;
    setSequenceIndex(sequenceList.value.length - 1);
  }

  void deleteSequence(int index) {
    print("deleting sequence $index");
    int length = sequenceList.value.length;
    sequenceList.value = List.from(sequenceList.value)..removeAt(index);
    sequenceSaveList.value = List.from(sequenceSaveList.value)..removeAt(index);
    sequenceTextList.value = List.from(sequenceTextList.value)..removeAt(index);
    cellTextList.value = List.from(cellTextList.value)..removeAt(index);
    commentsTextList.value = List.from(commentsTextList.value)..removeAt(index);

    SequenceBuilderKeepAliveClient sw = sequenceWidgets.value.elementAt(index)
        as SequenceBuilderKeepAliveClient;
    backend.sequenceRemove(sw.sequenceTextController.text.toNativeUtf8());
    sw.keepAliveUpdate();
    sequenceWidgets.value = List.from(sequenceWidgets.value)..removeAt(index);

    //just goto last index if we're deleting last index
    if (index == (length - 1)) {
      setSequenceIndex(sequenceList.value.length - 1);
    } else
      setSequenceIndex(index);

    //never want the list to be completey empty
    if (sequenceList.value.isEmpty) addNewSequence();
  }

  void saveSequence(int index) {
    SequenceBuilderKeepAliveClient sw = sequenceWidgets.value.elementAt(index)
        as SequenceBuilderKeepAliveClient;
    if (sw.sequenceTextController.text.isEmpty) {
      sw.setSequenceTextError(true);
      return;
    } else if (sw.sequenceTextError) {
      sw.setSequenceTextError(false);
    }

    //we made it to a save
    sequenceSaveList.value = List.from(sequenceSaveList.value)..[index] = true;
    sequenceList.value = List.from(sequenceList.value)
      ..[index] = sw.sequenceTextController.text;
    sequenceTextList.value = List.from(sequenceTextList.value)
      ..[index] = sw.sequenceTextController.text;
    cellTextList.value = List.from(cellTextList.value)
      ..[index] = sw.cellTextController.text;
    commentsTextList.value = List.from(commentsTextList.value)
      ..[index] = sw.commentsTextController.text;

    backend.startSaveSequence(
        sw.sequenceTextController.text.toNativeUtf8(),
        sw.cellTextController.text.toNativeUtf8(),
        sw.commentsTextController.text.toNativeUtf8());

    for (int i = 0; i < sw.table.length; i++) {
      List<dynamic> step = sw.table.elementAt(i);
      backend.addSaveSequenceStep(step.elementAt(0), step.elementAt(1),
          step.elementAt(2), step.elementAt(3));

      List<dynamic> tests = step.elementAt(4);
      for (int k = 0; k < tests.length; k++) {
        List<dynamic> t = tests.elementAt(k);
        backend.addSaveSequenceTest(t.elementAt(0), t.elementAt(1),
            t.elementAt(2), t.elementAt(3), t.elementAt(4));
      }
    }

    backend.finishSaveSequence();
  }

  void setSequenceIndex(int index) {
    selectedSequence.value = index;
    pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    sequenceList = useState(<String>["New Profile"]);
    selectedSequence = useState<int>(sequenceList.value.length - 1);
    sequenceTextList = useState(<String>[""]);
    cellTextList = useState(<String>[""]);
    commentsTextList = useState(<String>[""]);

    sequenceSaveList = useState(<bool>[false]);

    sequenceWidgets = useState(<Widget>[
      SequenceBuilderKeepAliveClient(
        key: UniqueKey(),
        pageIndex: totalPageCount - 1,
        currentIndex: 0,
      )
    ]);

    backend = Provider.of<KeysightCAPI>(context, listen: false);

    useMemoized(() {
      backend.loadAllSequences();
      pageController = PageController(initialPage: 0, keepPage: false);
    });

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
                            onPressed: !sequenceSaveList.value
                                    .elementAt(selectedSequence.value)
                                ? null
                                : () => deleteSequence(selectedSequence.value),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.red,
                              onSurface: Colors.grey,
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
            child: PageView(
              children: sequenceWidgets.value,
              controller: pageController,
              onPageChanged: (int index) {},
            ),
          )
        ],
      ),
    );
  }
}

class SequenceBuilderKeepAliveClient extends StatefulWidget {
  SequenceBuilderKeepAliveClient(
      {Key? key, required this.pageIndex, required this.currentIndex})
      : super(key: key);

  int pageIndex;
  int currentIndex;

  final TextEditingController sequenceTextController = TextEditingController();
  final TextEditingController cellTextController = TextEditingController();
  final TextEditingController commentsTextController = TextEditingController();
  late _SequenceBuilderKeepAliveClientState client;

  void setSequenceTextError(bool flag) {
    sequenceTextError = flag;
    client.refresh();
  }

  void keepAliveUpdate() {
    wantKeepAlive = false;
    client.keepAliveUpdate();
  }

  bool sequenceTextError = false;

  bool wantKeepAlive = true;

  List<List<dynamic>> table = <List<dynamic>>[];

  @override
  _SequenceBuilderKeepAliveClientState createState() {
    client = _SequenceBuilderKeepAliveClientState();
    return client;
  }
}

class _SequenceBuilderKeepAliveClientState
    extends State<SequenceBuilderKeepAliveClient>
    with AutomaticKeepAliveClientMixin<SequenceBuilderKeepAliveClient> {
  int dataTableSelectedIndex = -1;

  void refresh() {
    setState(() {});
  }

  void addTableStep(List<dynamic> step) {
    setState(() {
      widget.table.add(step);
    });
  }

  void addTableTest(List<dynamic> test) {
    setState(() {
      List<int> indexes = List.filled(2, 0, growable: true);
      indexes = getTableIndexes(dataTableSelectedIndex);

      widget.table.elementAt(indexes.elementAt(0)).elementAt(4).add(test);
    });
  }

  List<int> getTableIndexes(int index) {
    List<int> result = List.filled(2, 0, growable: false);

    int mainIndex = 0;
    int secondIndex = -1;
    int totalIndex = 0;
    bool nestedBreak = false;

    for (var element in widget.table) {
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

  void keepAliveUpdate() {
    updateKeepAlive();
  }

  bool moveUpPossible() {
    bool result = false;

    List<int> mapping = getTableIndexes(dataTableSelectedIndex);

    if (mapping.elementAt(1) >= 0) {
      result = false;
    } else if (dataTableSelectedIndex <= 0) {
      result = false;
    } else {
      result = true;
    }

    return result;
  }

  bool moveDownPossible() {
    bool result = false;

    List<int> mapping = getTableIndexes(dataTableSelectedIndex);

    if (dataTableSelectedIndex < 0) {
      result = false;
    } else if (mapping.elementAt(1) >= 0) {
      result = false;
    } else if (mapping.elementAt(0) < widget.table.length - 1) {
      result = true;
    } else {
      result = false;
    }

    return result;
  }

  void moveUp() {
    setState(() {
      List<int> mapping = getTableIndexes(dataTableSelectedIndex);

      if (mapping.elementAt(1) < 0) {
        dynamic removedItem = widget.table.elementAt(mapping.elementAt(0));
        widget.table.removeAt(mapping.elementAt(0));
        widget.table.insert(mapping.elementAt(0) - 1, removedItem);
      }
    });
  }

  void moveDown() {
    setState(() {
      List<int> mapping = getTableIndexes(dataTableSelectedIndex);

      if (mapping.elementAt(1) < 0) {
        widget.table = List.from(widget.table);
        dynamic removedItem = widget.table.elementAt(mapping.elementAt(0));
        widget.table.removeAt(mapping.elementAt(0));
        widget.table.insert(mapping.elementAt(0) + 1, removedItem);
      }
    });
  }

  void deleteStep() {
    setState(() {
      List<int> mapping = getTableIndexes(dataTableSelectedIndex);

      if (mapping.elementAt(1) >= 0) {
        widget.table = List.from(widget.table)
          ..elementAt(mapping.elementAt(0))
              .elementAt(4)
              .removeAt(mapping.elementAt(1));
      } else {
        widget.table = List.from(widget.table)..removeAt(mapping.elementAt(0));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
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
                    controller: widget.sequenceTextController,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      border: OutlineInputBorder(),
                      hintText: "Enter Name of Profile Sequence",
                      hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                          fontStyle: FontStyle.italic),
                      errorText: widget.sequenceTextError
                          ? "A Name of a Sequence Must be Given"
                          : null,
                      filled: true,
                      fillColor: Colors.grey.shade800,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z_ ]"))
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
                    controller: widget.cellTextController,
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
              controller: widget.commentsTextController,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                border: OutlineInputBorder(),
                hintText: "Include any additional comments here.",
                hintStyle: TextStyle(
                    color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                filled: true,
                fillColor: Colors.grey.shade800,
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(
              height: 12,
            ),
            SequenceStepTable(
              table: widget.table,
              onIndexChanged: (p0) {
                setState(() {
                  dataTableSelectedIndex = p0;
                });
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
                  onPressed: (dataTableSelectedIndex == -1)
                      ? null
                      : () => RouterUtility.routerUtility(context,
                              AddSequenceTestWidget(
                            onSave: (int testType, int testAction, double value,
                                int timeType, int timeLimit) {
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
                  onPressed: (dataTableSelectedIndex == -1)
                      ? null
                      : () {
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
    );
    ;
  }

  @override
  bool get wantKeepAlive => widget.wantKeepAlive;
}
