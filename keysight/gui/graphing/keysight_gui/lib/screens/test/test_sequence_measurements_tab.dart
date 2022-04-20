import 'package:flutter/material.dart';
import 'package:keysight_gui/screens/measurements/measurement_table_widget.dart';

class TestSequenceMeasurementsTab extends StatelessWidget {
  const TestSequenceMeasurementsTab({Key? key, required this.sequenceNumber})
      : super(key: key);

  final int sequenceNumber;

  @override
  Widget build(BuildContext context) {
    return MeasurementTableWidget(
      sequenceNumber: sequenceNumber,
    );
  }
}
