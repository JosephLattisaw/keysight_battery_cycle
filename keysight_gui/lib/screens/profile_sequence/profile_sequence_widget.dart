import 'package:ffi/ffi.dart';
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
  const ProfileSequenceWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sequenceList = useState(<String>["New Profile"]);
    final selectedSequence = useState<int>(sequenceList.value.length - 1);
    final sequenceTextList = useState(<String>[""]);
    final cellTextList = useState(<String>[""]);
    final commentsTextList = useState(<String>[""]);

    final sequenceSaveList = useState(<bool>[false]);
    final totalPageCount = useState(-1);

    final sequenceWidgets = useState(<Widget>[
      SequenceBuilderKeepAliveClient(
          key: UniqueKey(),
          pageIndex: totalPageCount.value + 1,
          onChanged: (int index) {
            print("on changed $index");
            sequenceSaveList.value = List.from(sequenceSaveList.value)
              ..[index] = false;
          })
    ]);

    final backend = Provider.of<KeysightCAPI>(context, listen: false);
    final pageController = usePageController(initialPage: 0, keepPage: false);

    void setSequenceIndex(int index) {
      selectedSequence.value = index;
      pageController.jumpToPage(index);
    }

    void addNewSequence(
        {String name = "New Profile",
        bool saved = false,
        String sequenceText = "",
        String cellText = "",
        String commentsText = ""}) {
      sequenceList.value = List.from(sequenceList.value)..add(name);
      sequenceSaveList.value = List.from(sequenceSaveList.value)..add(saved);
      sequenceTextList.value = List.from(sequenceTextList.value)
        ..add(sequenceText);
      cellTextList.value = List.from(cellTextList.value)..add(cellText);
      commentsTextList.value = List.from(commentsTextList.value)
        ..add(commentsText);

      sequenceWidgets.value.add(SequenceBuilderKeepAliveClient(
          key: UniqueKey(),
          pageIndex: totalPageCount.value + 1,
          onChanged: (int index) {
            print("on changed $index");
            sequenceSaveList.value = List.from(sequenceSaveList.value)
              ..[index] = false;
          }));

      totalPageCount.value++;
      setSequenceIndex(sequenceList.value.length - 1);
    }

    void deleteSequence(int index, {bool addNew = true}) {
      int length = sequenceList.value.length;
      sequenceList.value = List.from(sequenceList.value)..removeAt(index);
      sequenceSaveList.value = List.from(sequenceSaveList.value)
        ..removeAt(index);
      sequenceTextList.value = List.from(sequenceTextList.value)
        ..removeAt(index);
      cellTextList.value = List.from(cellTextList.value)..removeAt(index);
      commentsTextList.value = List.from(commentsTextList.value)
        ..removeAt(index);

      SequenceBuilderKeepAliveClient sw = sequenceWidgets.value.elementAt(index)
          as SequenceBuilderKeepAliveClient;
      final st = sw.sequenceTextController.text.toNativeUtf8();
      backend.sequenceRemove(st);
      backend.deleteSavedSeqeunce(sw.sequenceTextController.text);
      calloc.free(st);
      sw.keepAliveUpdate();
      sequenceWidgets.value = List.from(sequenceWidgets.value)..removeAt(index);

      //reset all the indexes
      for (int i = 0; i < sequenceWidgets.value.length; i++) {
        SequenceBuilderKeepAliveClient sw = sequenceWidgets.value.elementAt(i)
            as SequenceBuilderKeepAliveClient;

        sw.updateIndex(i);
      }

      //just goto last index if we're deleting last index
      if (index == (length - 1)) {
        setSequenceIndex(sequenceList.value.length - 1);
      } else {
        setSequenceIndex(index);
      }

      //never want the list to be completey empty
      if (sequenceList.value.isEmpty && addNew) addNewSequence();
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
      sequenceSaveList.value = List.from(sequenceSaveList.value)
        ..[index] = true;
      sequenceList.value = List.from(sequenceList.value)
        ..[index] = sw.sequenceTextController.text;
      sequenceTextList.value = List.from(sequenceTextList.value)
        ..[index] = sw.sequenceTextController.text;
      cellTextList.value = List.from(cellTextList.value)
        ..[index] = sw.cellTextController.text;
      commentsTextList.value = List.from(commentsTextList.value)
        ..[index] = sw.commentsTextController.text;

      final st = sw.sequenceTextController.text.toNativeUtf8();
      final ct = sw.cellTextController.text.toNativeUtf8();
      final co = sw.commentsTextController.text.toNativeUtf8();

      backend.startSaveSequence(st, ct, co);
      calloc.free(st);
      calloc.free(ct);
      calloc.free(co);

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
      backend.addSavedSequence(sw.sequenceTextController.text);
    }

    useMemoized(() {
      print("how often does this shit get called");
      Future.delayed(Duration.zero, () async {
        final loadedSequences = backend.getLoadedSequences;
        print("found ${loadedSequences.length} $loadedSequences");
        for (int i = 0; i < loadedSequences.length; i++) {
          final List<dynamic> info = loadedSequences.elementAt(i);
          final String name = info.elementAt(0);
          final String serial = info.elementAt(1);
          final String comments = info.elementAt(2);
          final List<dynamic> steps = info.elementAt(3);

          addNewSequence(
              name: name,
              saved: true,
              sequenceText: name,
              cellText: serial,
              commentsText: comments);

          //i+1 because presumably there will be a default blank one
          //that we'll delete later
          SequenceBuilderKeepAliveClient sw = sequenceWidgets.value
              .elementAt(i + 1) as SequenceBuilderKeepAliveClient;

          sw.sequenceTextController.text = name;
          sw.cellTextController.text = serial;
          sw.commentsTextController.text = comments;

          print("loaded $loadedSequences");
          int stepIndex = -1;
          for (int k = 0; k < steps.length; k++) {
            List<dynamic> step = steps.elementAt(k);
            print("steps: $k $step");
            final mode = step.elementAt(0);
            final seconds = step.elementAt(1);
            final current = step.elementAt(2);
            final voltage = step.elementAt(3);
            final List<dynamic> tests = step.elementAt(4);

            sw.addTableStep([mode, seconds, current, voltage, []]);
            stepIndex++;

            for (int j = 0; j < tests.length; j++) {
              final List<dynamic> test = tests.elementAt(j);
              final test_type = test.elementAt(0);
              final test_action = test.elementAt(1);
              final value = test.elementAt(2);
              final time_type = test.elementAt(3);
              final time_limit = test.elementAt(4);
              sw.addTableTest(
                  [test_type, test_action, value, time_type, time_limit],
                  stepIndex);
              stepIndex++;
            }
          }
        }

        if (loadedSequences.length > 0) deleteSequence(0);
      });
    });

    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.only(left: 12.0, top: 12.0, bottom: 12.0),
            child: Column(
              children: [
                const Text(
                  "Save, Create or Delete Profile Sequences:",
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => saveSequence(selectedSequence.value),
                        child: const Text(
                          "Save",
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => addNewSequence(),
                        child: const Text("New"),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: !sequenceSaveList.value
                                .elementAt(selectedSequence.value)
                            ? null
                            : () => deleteSequence(selectedSequence.value),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red,
                          onSurface: Colors.grey,
                        ),
                        child: const Text("Delete"),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
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
    );
  }
}

class SequenceBuilderKeepAliveClient extends StatefulWidget {
  SequenceBuilderKeepAliveClient(
      {Key? key, required this.pageIndex, required this.onChanged})
      : super(key: key);

  int pageIndex;

  final void Function(int) onChanged;

  final TextEditingController sequenceTextController = TextEditingController();
  final TextEditingController cellTextController = TextEditingController();
  final TextEditingController commentsTextController = TextEditingController();
  late final _SequenceBuilderKeepAliveClientState client;
  List<List<dynamic>> table = <List<dynamic>>[];

  void setSequenceTextError(bool flag) {
    client.sequenceTextError = flag;
    client.refresh();
  }

  void updateIndex(int index) {
    print("update index called $index $pageIndex");
    pageIndex = index;
  }

  bool get sequenceTextError => client.sequenceTextError;

  void keepAliveUpdate() {
    client.wantKeepAlive_ = false;
    client.keepAliveUpdate();
  }

  //this doesn't do anything if the state hasn't been called yet
  void addTableStep(List<dynamic> step) {
    table.add(step);
  }

  void editTableStep(int index, List<dynamic> step) {
    table[index][0] = step.elementAt(0);
    table[index][1] = step.elementAt(1);
    table[index][2] = step.elementAt(2);
    table[index][3] = step.elementAt(3);
  }

  void editTableTest(int tableIndex, int testIndex, List<dynamic> test) {
    table[tableIndex][4][testIndex] = test;
  }

  List<int> getTableIndexes(int index) {
    List<int> result = List.filled(2, 0, growable: false);

    int mainIndex = 0;
    int secondIndex = -1;
    int totalIndex = 0;
    bool nestedBreak = false;

    for (var element in table) {
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

  void addTableTest(List<dynamic> test, int index) {
    List<int> indexes = List.filled(2, 0, growable: true);
    indexes = getTableIndexes(index);

    table.elementAt(indexes.elementAt(0)).elementAt(4).add(test);
  }

  bool get wantKeepAlive => client.wantKeepAlive_;

  //List<List<dynamic>> get table => client.table;

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
  bool sequenceTextError = false;
  bool wantKeepAlive_ = true;

  void refresh() {
    setState(() {});
  }

  void addTableStep(List<dynamic> step) {
    setState(() {
      widget.addTableStep(step);
      widget.onChanged(widget.pageIndex);
    });
  }

  void editTableStep(int index, List<dynamic> step) {
    setState(() {
      widget.editTableStep(index, step);
      widget.onChanged(widget.pageIndex);
    });
  }

  void editTableTest(int tableIndex, int testIndex, List<dynamic> test) {
    setState(() {
      widget.editTableTest(tableIndex, testIndex, test);
      widget.onChanged(widget.pageIndex);
    });
  }

  void addTableTest(List<dynamic> test) {
    setState(() {
      widget.addTableTest(test, dataTableSelectedIndex);
      widget.onChanged(widget.pageIndex);
    });
  }

  void keepAliveUpdate() {
    updateKeepAlive();
  }

  bool moveUpPossible() {
    bool result = false;

    List<int> mapping = widget.getTableIndexes(dataTableSelectedIndex);

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

    List<int> mapping = widget.getTableIndexes(dataTableSelectedIndex);

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

  bool isTable() {
    bool result = true;

    List<int> mapping = widget.getTableIndexes(dataTableSelectedIndex);

    if (mapping.elementAt(1) >= 0) {
      result = false;
    }

    return result;
  }

  void moveUp() {
    setState(() {
      List<int> mapping = widget.getTableIndexes(dataTableSelectedIndex);

      if (mapping.elementAt(1) < 0) {
        dynamic removedItem = widget.table.elementAt(mapping.elementAt(0));
        widget.table.removeAt(mapping.elementAt(0));
        widget.table.insert(mapping.elementAt(0) - 1, removedItem);
      }
    });
  }

  void moveDown() {
    setState(() {
      List<int> mapping = widget.getTableIndexes(dataTableSelectedIndex);

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
      List<int> mapping = widget.getTableIndexes(dataTableSelectedIndex);

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
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      border: const OutlineInputBorder(),
                      hintText: "Enter Name of Profile Sequence",
                      hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                          fontStyle: FontStyle.italic),
                      errorText: sequenceTextError
                          ? "A Name of a Sequence Must be Given"
                          : null,
                      filled: true,
                      fillColor: Colors.grey.shade800,
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            /*const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: widget.cellTextController,
                    decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      border: const OutlineInputBorder(),
                      hintText: "Enter Serial Number of Cell",
                      hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                          fontStyle: FontStyle.italic),
                      filled: true,
                      fillColor: Colors.grey.shade800,
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),*/
            const SizedBox(height: 12),
            TextField(
              controller: widget.commentsTextController,
              decoration: InputDecoration(
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                border: const OutlineInputBorder(),
                hintText: "Include any additional comments here.",
                hintStyle: TextStyle(
                    color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                filled: true,
                fillColor: Colors.grey.shade800,
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            SequenceStepTable(
              table: widget.table,
              onIndexChanged: (p0) {
                setState(() {
                  dataTableSelectedIndex = p0;
                });
              },
            ),
            const SizedBox(height: 12),
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
                  child: const Text("Add Step"),
                ),
                const SizedBox(width: 4),
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
                  child: const Text("Add Test"),
                  style: ElevatedButton.styleFrom(
                    onSurface: Colors.grey,
                  ),
                ),
                const SizedBox(width: 4),
                ElevatedButton(
                  onPressed: (dataTableSelectedIndex >= 0)
                      ? () {
                          List<int> mapping =
                              widget.getTableIndexes(dataTableSelectedIndex);
                          final table =
                              widget.table.elementAt(mapping.elementAt(0));

                          if (isTable()) {
                            final mode = table.elementAt(0);
                            final seconds = table.elementAt(1);
                            final current = table.elementAt(2);
                            final voltage = table.elementAt(3);

                            print("edit: $table");

                            RouterUtility.routerUtility(
                                context,
                                AddSequenceStepWidget(
                                  editing: true,
                                  initialMode: mode,
                                  initialDurationSeconds: seconds,
                                  initialCurrentLimit: current,
                                  initialVoltageLimit: voltage,
                                  onSave: (int mode, int seconds,
                                      double current, double voltage) {
                                    editTableStep(
                                        mapping.elementAt(0), <dynamic>[
                                      mode,
                                      seconds,
                                      current,
                                      voltage
                                    ]);
                                  },
                                ));
                          } else {
                            final test = table
                                .elementAt(4)
                                .elementAt(mapping.elementAt(1));

                            final testType = test.elementAt(0);
                            final testAction = test.elementAt(1);
                            final value = test.elementAt(2);
                            final timeType = test.elementAt(3);
                            final timeLimit = test.elementAt(4);

                            RouterUtility.routerUtility(
                                context,
                                AddSequenceTestWidget(
                                  editing: true,
                                  initialTestAction: testAction,
                                  initialTestType: testType,
                                  initialTimeLimit: timeLimit,
                                  initialTimeType: timeType,
                                  initialValue: value,
                                  onSave: (int testType,
                                      int testAction,
                                      double value,
                                      int timeType,
                                      int timeLimit) {
                                    editTableTest(mapping.elementAt(0),
                                        mapping.elementAt(1), <dynamic>[
                                      testType,
                                      testAction,
                                      value,
                                      timeType,
                                      timeLimit
                                    ]);
                                  },
                                ));
                          }
                        }
                      : null,
                  child: const Text("Edit"),
                  style: ElevatedButton.styleFrom(
                    onSurface: Colors.grey,
                  ),
                ),
                const SizedBox(width: 32),
                ElevatedButton(
                  onPressed: !moveUpPossible()
                      ? null
                      : () {
                          moveUp();
                        },
                  child: const Text("Move Up"),
                  style: ElevatedButton.styleFrom(
                    onSurface: Colors.grey,
                  ),
                ),
                const SizedBox(width: 4),
                ElevatedButton(
                  onPressed: !moveDownPossible()
                      ? null
                      : () {
                          moveDown();
                        },
                  child: const Text("Move Down"),
                  style: ElevatedButton.styleFrom(
                    onSurface: Colors.grey,
                  ),
                ),
                const SizedBox(width: 32),
                ElevatedButton(
                  onPressed: (dataTableSelectedIndex == -1)
                      ? null
                      : () {
                          deleteStep();
                        },
                  child: const Text("Delete Step"),
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
  }

  @override
  bool get wantKeepAlive => wantKeepAlive_;
}
