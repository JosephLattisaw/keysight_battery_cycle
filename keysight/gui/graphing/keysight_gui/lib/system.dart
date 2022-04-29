import 'package:flutter/material.dart';
import 'package:keysight_gui/screens/measurements/measurement_widget.dart';
import 'package:keysight_gui/screens/test/test_sequence_chart_tab.dart';
import 'package:keysight_gui/tab_widget.dart';

class SystemPage extends StatelessWidget {
  List<String> sequences = ["1", "2", "3", "4", "5", "6", "7", "8"];
  List<String> profileNames = [
    "Timed Charge",
    "CCV",
    "Ramp Slow / Discharge Fast",
    "Timed Charge",
    "Ramp Slow / Discharge Fast",
    "Timed Charge",
    "CCV",
    "Timed Charge"
  ];

  List<String> statuses = [
    "RUNNING",
    "NOT RUNNING",
    "FAILED",
    "NOT RUNNING",
    "RUNNING",
    "NOT RUNNING",
    "RUNNING",
    "NOT RUNNING"
  ];

  final List<int> statuses1 = [1, 0, 2, 0, 1, 0, 1, 0];

  List<String> times = [
    "3d 12hr 10m 35s",
    "3d 12hr 10m 35s",
    "N/A",
    "3d 12hr 10m 35s",
    "14d 1hr 0m 10s",
    "3d 12hr 2m 35s",
    "0d 0hr 0m 10s",
    "0d 0hr 0m 10s",
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TabWidget(
        useShadow: false,
        tabs: const [
          Text("Test Status"),
          Text("Measurements"),
          Text("Chart"),
        ],
        tabWidgets: [
          SingleChildScrollView(
            primary: false,
            child: DataTable(
              headingRowColor: MaterialStateColor.resolveWith(
                  (states) => Colors.blue.shade900),
              columns: [
                DataColumn(
                  label: Text(
                    'Test #',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Profile Name',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Status',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Total Time Running',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Current Time Running',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Cycles',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Cells',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
              rows: List<DataRow>.generate(
                8,
                (index) => DataRow(
                  color: MaterialStateProperty.resolveWith<Color>((states) {
                    if (index % 2 == 0) return Colors.grey.shade700;
                    return Colors.grey.shade800;
                  }),
                  cells: <DataCell>[
                    DataCell(
                      Text(
                        sequences.elementAt(index),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    DataCell(
                      Text(
                        profileNames.elementAt(index),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    DataCell(
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                statuses.elementAt(index),
                                style: TextStyle(
                                    color: (statuses1.elementAt(index) > 0)
                                        ? (statuses1.elementAt(index) == 1
                                            ? Colors.green
                                            : Colors.red)
                                        : Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    DataCell(
                      Text(
                        times.elementAt(index),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    DataCell(
                      Text(
                        times.elementAt(index),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    DataCell(
                      Text(
                        "1",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    DataCell(
                      ElevatedButton(
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.grey.shade800,
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          MeasurementWidget(
            key: UniqueKey(),
          ),
          TestSequenceChartTab(),
        ],
      ),
    );
  }
}
