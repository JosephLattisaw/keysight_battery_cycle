import 'package:flutter/material.dart';
import 'package:keysight_gui/keysight_c_api.dart';
import 'package:keysight_gui/router_utility.dart';
import 'package:keysight_gui/screens/measurements/measurement_table_scaffold.dart';
import 'package:keysight_gui/screens/measurements/measurement_widget.dart';
import 'package:keysight_gui/screens/profile_sequence/add_sequence_step_widget.dart';
import 'package:keysight_gui/screens/test/test_sequence_chart_tab.dart';
import 'package:keysight_gui/tab_widget.dart';
import 'package:provider/provider.dart';

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

  String getTimeString(double seconds) {
    int secs = seconds.toInt();
    int minutes = secs ~/ 60;
    int hours = minutes ~/ 60;
    int days = hours ~/ 24;

    String res = "${days}d ${hours % 24}h ${minutes % 60}m ${secs % 60}s";
    return res;
  }

  String getSlotStatusText(int value) {
    switch (value) {
      case 1:
        return "FAILED";
      case 2:
        return "RUNNING";
      case 3:
        return "ABORTED, HARD LIMIT";
      case 4:
        return "RUNNING, SOFT LIMIT";
      case 5:
        return "COMPLETED";
      default:
        return "NOT RUNNING";
    }
  }

  Color getSlotColor(int value) {
    switch (value) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.green;
      case 3:
        return Colors.red;
      case 4:
        return Colors.amber;
      case 5:
        return Colors.blue;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sequencesStartedSlots =
        context.select((KeysightCAPI k) => k.sequencesStartedSlots);
    final loadedProfiles = context.select((KeysightCAPI k) => k.loadedProfiles);
    final slotStatuses = context.select((KeysightCAPI k) => k.slotStatuses);
    final timeStatuses = context.select((KeysightCAPI k) => k.timeStatuses);
    final timeTotalStatuses =
        context.select((KeysightCAPI k) => k.timeTotalStatuses);
    final cycleStatuses = context.select((KeysightCAPI k) => k.cycleStatuses);

    print("time statuses: $timeStatuses");

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TabWidget(
        useShadow: false,
        tabs: const [
          Text("Test Status"),
          Text("Live Measurements"),
          //Text("Chart"),
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
                        sequencesStartedSlots.elementAt(index) == -1
                            ? "N/A"
                            : loadedProfiles.elementAt(
                                sequencesStartedSlots.elementAt(index)),
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
                                  getSlotStatusText(
                                      slotStatuses.elementAt(index)),
                                  style: TextStyle(
                                    color: getSlotColor(
                                        slotStatuses.elementAt(index)),
                                  )),
                            ],
                          ),
                        ],
                      ),
                    ),
                    DataCell(
                      Text(
                        getTimeString(timeTotalStatuses.elementAt(index)),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    DataCell(
                      Text(
                        getTimeString(timeStatuses.elementAt(index)),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    DataCell(
                      Text(
                        cycleStatuses.elementAt(index).toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    DataCell(
                      ElevatedButton(
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.grey.shade800,
                        ),
                        onPressed: () => RouterUtility.routerUtility(
                            context,
                            MeasurementTableScaffold(
                              sequenceNumber: index,
                            )),
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
          //TestSequenceChartTab(),
        ],
      ),
    );
  }
}
