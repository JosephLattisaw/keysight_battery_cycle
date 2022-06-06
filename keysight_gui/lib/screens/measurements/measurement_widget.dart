import 'package:flutter/material.dart';
import 'package:keysight_gui/screens/measurements/measurement_table_widget.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class MeasurementWidget extends HookWidget {
  const MeasurementWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final speedComboBoxSelection = useState(0);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(child: MeasurementTableWidget()),
        ],
      ),
    );
  }
}
