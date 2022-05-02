import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:keysight_gui/application_bar.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:keysight_gui/screens/measurements/measurement_table_widget.dart';
import 'package:keysight_gui/screens/profile_sequence/common_profile_sequence.dart';

class MeasurementTableScaffold extends HookWidget {
  MeasurementTableScaffold({Key? key, required this.sequenceNumber})
      : super(key: key);

  int sequenceNumber;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        child: const ApplicationBar(),
        preferredSize: AppBar().preferredSize,
      ),
      backgroundColor: Colors.black,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: MeasurementTableWidget(
          sequenceNumber: sequenceNumber,
        ),
      ),
    );
  }
}
