import 'package:flutter/material.dart';
import 'package:keysight_gui/screens/test/test_sequence_cells_tab.dart';
import 'package:keysight_gui/screens/test/test_sequence_measurements_tab.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:keysight_gui/tab_widget.dart';
import 'package:keysight_gui/screens/test/test_sequence_chart_tab.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class TestTabbedWidget extends HookWidget {
  TestTabbedWidget({Key? key, required this.sequenceNumber}) : super(key: key);

  final int sequenceNumber;

  @override
  Widget build(BuildContext context) {
    final canStartSequence = useState(false);
    final sequenceStarted = useState(false);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(left: 20, top: 8, right: 8, bottom: 8),
              child: Row(
                children: [
                  ElevatedButton(onPressed: () {}, child: Text("Browse")),
                  SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        border: OutlineInputBorder(),
                        hintText:
                            "Select a .csv File to Log Telemetry to a file",
                        hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontStyle: FontStyle.italic),
                        filled: true,
                        fillColor: Colors.grey.shade800,
                        isDense: true,
                        contentPadding: const EdgeInsets.all(14.0),
                      ),
                      style: TextStyle(color: Colors.white, fontSize: 14.0),
                      readOnly: true,
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: TabWidget(
                  useShadow: false,
                  tabs: [
                    Text("Channels / Cells"),
                    Text("Measurements"),
                    Text("Chart"),
                  ],
                  tabWidgets: [
                    TestSequenceCellsTab(canStartSequence: ((value) {
                      canStartSequence.value = value;
                    })),
                    TestSequenceMeasurementsTab(),
                    TestSequenceChartTab(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  bottom: 20, left: 20, right: 20, top: 8),
              child: Row(
                children: [
                  IntrinsicWidth(
                    child: DropdownButtonFormField(
                      value: 0,
                      items: [
                        DropdownMenuItem(child: Text("1 Second"), value: 0),
                        DropdownMenuItem(child: Text("10 Seconds"), value: 1),
                        DropdownMenuItem(child: Text("30 Seconds"), value: 2),
                        DropdownMenuItem(child: Text("60 seconds"), value: 3),
                        DropdownMenuItem(child: Text("5 minutes"), value: 4),
                        DropdownMenuItem(child: Text("10 minutes"), value: 5),
                      ],
                      onChanged: (int? value) {},
                      style: TextStyle(color: Colors.white),
                      dropdownColor: Colors.blueAccent,
                      iconEnabledColor: Colors.white,
                      icon: Icon(Icons.arrow_drop_down),
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black, width: 1.4),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue, width: 2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        filled: true,
                        fillColor: Colors.blueAccent,
                        isDense: true,
                        contentPadding: const EdgeInsets.all(8.0),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    "<-- Select a Sequence From the Dropwdown Menu",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: !canStartSequence.value
                        ? null
                        : () {
                            sequenceStarted.value = !sequenceStarted.value;
                          },
                    child: Text(!sequenceStarted.value
                        ? "Stop Sequence"
                        : "Start Sequence"),
                    style: ElevatedButton.styleFrom(
                      primary:
                          !sequenceStarted.value ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
