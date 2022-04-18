import 'package:flutter/material.dart';
import 'package:keysight_gui/screens/instrument_connection/instrument_widget.dart';
import 'package:keysight_gui/screens/measurements/measurement_widget.dart';
import 'package:keysight_gui/screens/profile_sequence/profile_sequence_widget.dart';
import 'package:keysight_gui/tab_widget.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:keysight_gui/screens/test/test_tabbed_widget.dart';

class TestWidget extends StatelessWidget {
  TestWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: TabWidget(
                tabs: List.generate(8, (index) => Text("Test #${index + 1}")),
                tabWidgets: List.generate(
                    8,
                    (index) => TestTabbedWidget(
                          sequenceNumber: index,
                        )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
