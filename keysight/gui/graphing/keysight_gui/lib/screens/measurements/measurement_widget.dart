import 'package:flutter/material.dart';
import 'package:keysight_gui/tab_widget.dart';

class MeasurementWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TabWidget(
          tabs: [
            Text("Voltage(V)"),
            Text("Current(A)"),
            Text("Capacity(A)"),
            Text("Status"),
          ],
          tabWidgets: [
            Text("a"),
            Text("b"),
            Text("a"),
            Text("b"),
          ],
        ),
      ),
    );
  }
}
