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

  @override
  Widget build(BuildContext context) {
    final canStartSequence = useState(false);
    final sequenceStarted = context.select(
        (KeysightCAPI k) => k.sequencesStarted.elementAt(sequenceNumber));
    final cApi = Provider.of<KeysightCAPI>(context, listen: false);

    final checkCount = useState(
        List<List<bool>>.generate(8, (index) => List<bool>.filled(32, false)));

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(left: 20, top: 8, right: 8, bottom: 8),
            child: Row(
              children: [
                ElevatedButton(onPressed: () {}, child: const Text("Browse")),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      border: const OutlineInputBorder(),
                      hintText: "Select a .csv File to Log Telemetry to a file",
                      hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                          fontStyle: FontStyle.italic),
                      filled: true,
                      fillColor: Colors.grey.shade800,
                      isDense: true,
                      contentPadding: const EdgeInsets.all(14.0),
                    ),
                    style: const TextStyle(color: Colors.white, fontSize: 14.0),
                    readOnly: true,
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TabWidget(
                useShadow: false,
                tabs: const [
                  Text("Channels / Cells"),
                  Text("Measurements"),
                  Text("Chart"),
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
                  const TestSequenceChartTab(),
                ],
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(bottom: 20, left: 20, right: 20, top: 8),
            child: Row(
              children: [
                IntrinsicWidth(
                  child: DropdownButtonFormField(
                    value: 0,
                    items: const [
                      DropdownMenuItem(child: Text("1 Second"), value: 0),
                      DropdownMenuItem(child: Text("10 Seconds"), value: 1),
                      DropdownMenuItem(child: Text("30 Seconds"), value: 2),
                      DropdownMenuItem(child: Text("60 seconds"), value: 3),
                      DropdownMenuItem(child: Text("5 minutes"), value: 4),
                      DropdownMenuItem(child: Text("10 minutes"), value: 5),
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
                const SizedBox(
                  width: 8,
                ),
                const Text(
                  "<-- Select a Sequence From the Dropwdown Menu",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: !canStartSequence.value && !sequenceStarted
                      ? null
                      : () {
                          Future.delayed(Duration.zero, () async {
                            cApi.setSequenceStarted(
                                sequenceNumber, !sequenceStarted);
                          });
                        },
                  child: Text(
                      sequenceStarted ? "Stop Sequence" : "Start Sequence"),
                  style: ElevatedButton.styleFrom(
                    primary: sequenceStarted ? Colors.red : Colors.green,
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
