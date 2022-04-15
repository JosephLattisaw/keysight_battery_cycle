import 'package:flutter/material.dart';
import 'package:keysight_gui/screens/instrument_connection/instrument_widget.dart';
import 'package:keysight_gui/screens/measurements/measurement_widget.dart';
import 'package:keysight_gui/screens/profile_sequence/profile_sequence_widget.dart';
import 'package:keysight_gui/tab_widget.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:keysight_gui/screens/test/test_tabbed_widget.dart';

class TestWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: TabWidget(
                tabs: [
                  Text("Test #1"),
                  Text("Test #2"),
                  Text("Test #3"),
                  Text("Test #4"),
                  Text("Test #5"),
                  Text("Test #6"),
                  Text("Test #7"),
                  Text("Test #8"),
                ],
                tabWidgets: [
                  TestTabbedWidget(),
                  TestTabbedWidget(),
                  TestTabbedWidget(),
                  TestTabbedWidget(),
                  TestTabbedWidget(),
                  TestTabbedWidget(),
                  TestTabbedWidget(),
                  TestTabbedWidget(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
