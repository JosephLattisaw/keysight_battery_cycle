import 'package:flutter/material.dart';
import 'package:keysight_gui/screens/test/test_sequence_cells_tab.dart';
import 'package:keysight_gui/screens/test/test_sequence_measurements_tab.dart';
import 'package:keysight_gui/tab_widget.dart';
import 'package:keysight_gui/screens/test/test_sequence_chart_tab.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:keysight_gui/keysight_c_api.dart';

class TestTabbedWidget extends HookWidget {
  const TestTabbedWidget({Key? key, required this.sequenceNumber})
      : super(key: key);

  final int sequenceNumber;

  String getDropDownText(int index, int value, String sequence) {
    String s = "Sequence ${index + 1}";

    if (value != 2) {
      s = s + ": INVALID";
    } else {
      s = s + ": " + sequence;
    }

    return s;
  }

  String getActionButtonText(bool started, int slotStatus) {
    switch (slotStatus) {
      case 3:
        return "Clear Hard Limit";
      case 4:
        return "Clear Soft Limit";
      default:
        return started ? "Stop Sequence" : "Start Sequence";
    }
  }

  Color getActionButtonColor(bool started, int slotStatus) {
    switch (slotStatus) {
      case 3:
        return Colors.red;
      case 4:
        return Colors.amber;
      default:
        return started ? Colors.red : Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final canStartSequence = useState(false);
    final sequenceStarted = context.select(
        (KeysightCAPI k) => k.sequencesStarted.elementAt(sequenceNumber));
    final cApi = Provider.of<KeysightCAPI>(context, listen: false);
    final profileStatuses =
        context.select((KeysightCAPI k) => k.profilesStatuses);
    final loadedProfiles = context.select((KeysightCAPI k) => k.loadedProfiles);
    final slotStatuses = context.select((KeysightCAPI k) => k.slotStatuses);

    final checkCount = useState(
        List<List<bool>>.generate(8, (index) => List<bool>.filled(32, false)));

    final dropdownStatus = useState(0);

    final successivelyCheckbox = useState(false);

    print(
        "seq started $sequenceStarted, canstart ${canStartSequence.value}, (${profileStatuses.elementAt(dropdownStatus.value)}");

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          Visibility(
            child: CheckboxListTile(
              title: Text(
                "Run Sequence Repeatedly",
                style: TextStyle(color: Colors.white),
              ),
              value: successivelyCheckbox.value,
              onChanged: (newValue) {
                successivelyCheckbox.value = newValue ?? false;
              },
              controlAffinity:
                  ListTileControlAffinity.leading, //  <-- leading Checkbox
            ),
            visible: !sequenceStarted,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TabWidget(
                useShadow: false,
                tabs: const [
                  Text("Channels / Cells"),
                  Text("Live Measurements"),
                  //Text("Chart"),
                ],
                tabWidgets: [
                  TestSequenceCellsTab(
                      canStartSequence: ((value, count) {
                        Future.delayed(Duration.zero, () async {
                          canStartSequence.value = value;
                          checkCount.value = count;
                        });
                      }),
                      sequenceStarted: sequenceStarted,
                      sequenceNumber: sequenceNumber),
                  TestSequenceMeasurementsTab(
                    sequenceNumber: sequenceNumber,
                  ),
                  //TestSequenceChartTab(),
                ],
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(bottom: 20, left: 20, right: 20, top: 8),
            child: Row(
              children: [
                Visibility(
                  visible: !sequenceStarted,
                  child: IntrinsicWidth(
                    child: DropdownButtonFormField(
                      value: dropdownStatus.value,
                      items: List.generate(
                          8,
                          (index) => DropdownMenuItem(
                              child: Text(
                                  getDropDownText(
                                      index,
                                      profileStatuses.elementAt(index),
                                      loadedProfiles.elementAt(index)),
                                  style: TextStyle(
                                      color:
                                          profileStatuses.elementAt(index) != 2
                                              ? Colors.red
                                              : Colors.white)),
                              value: index)),
                      onChanged: (int? value) {
                        dropdownStatus.value = value ?? 0;
                      },
                      style: const TextStyle(color: Colors.white),
                      dropdownColor: Colors.blueAccent,
                      iconEnabledColor: Colors.white,
                      icon: const Icon(Icons.arrow_drop_down),
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.black, width: 1.4),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        border: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.blue, width: 2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        filled: true,
                        fillColor: Colors.blueAccent,
                        isDense: true,
                        contentPadding: const EdgeInsets.all(8.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                Visibility(
                  visible: !sequenceStarted,
                  child: IntrinsicWidth(
                    child: DropdownButtonFormField(
                      value: 0,
                      items: [
                        DropdownMenuItem(
                            child: Text("Acceptance Test"), value: 0),
                        DropdownMenuItem(
                            child: Text("Lifecycle Test"), value: 1)
                      ],
                      onChanged: (int? value) {},
                      style: const TextStyle(color: Colors.white),
                      dropdownColor: Colors.blueAccent,
                      iconEnabledColor: Colors.white,
                      icon: const Icon(Icons.arrow_drop_down),
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.black, width: 1.4),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        border: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.blue, width: 2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        filled: true,
                        fillColor: Colors.blueAccent,
                        isDense: true,
                        contentPadding: const EdgeInsets.all(8.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Visibility(
                  child: const Text(
                    "<-- Select a Sequence & Test Type From the Dropdown Menu",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  visible: !sequenceStarted,
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: ((canStartSequence.value && !sequenceStarted) &&
                              (profileStatuses
                                      .elementAt(dropdownStatus.value) ==
                                  2)) ||
                          (sequenceStarted)
                      ? () {
                          Future.delayed(Duration.zero, () async {
                            int slotStatus =
                                slotStatuses.elementAt(sequenceNumber);
                            if (slotStatus == 4) {
                              print("clearing soft limit");
                              cApi.clearSoftLimit(sequenceNumber);
                            } else {
                              print("starting/stopping test");
                              cApi.setSequenceStarted(
                                  sequenceNumber,
                                  dropdownStatus.value,
                                  !sequenceStarted,
                                  successivelyCheckbox.value);
                            }
                          });
                        }
                      : null,
                  child: Text(getActionButtonText(
                      sequenceStarted, slotStatuses.elementAt(sequenceNumber))),
                  style: ElevatedButton.styleFrom(
                    primary: getActionButtonColor(sequenceStarted,
                        slotStatuses.elementAt(sequenceNumber)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
