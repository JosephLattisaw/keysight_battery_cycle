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
          Container(
            color: Colors.black,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Measurements",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                          color: Colors.grey.shade800,
                          border: Border.all(color: Colors.black38, width: 0),
                          boxShadow: const <BoxShadow>[
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.57),
                              blurRadius: 5,
                            )
                          ]),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: DropdownButton(
                          value: speedComboBoxSelection.value,
                          items: const [
                            DropdownMenuItem(child: Text("1 Second"), value: 0),
                            DropdownMenuItem(
                                child: Text("10 Seconds"), value: 1),
                            DropdownMenuItem(
                                child: Text("30 Seconds"), value: 2),
                            DropdownMenuItem(
                                child: Text("60 seconds"), value: 3),
                            DropdownMenuItem(
                                child: Text("5 minutes"), value: 4),
                            DropdownMenuItem(
                                child: Text("10 minutes"), value: 5),
                          ],
                          onChanged: (int? value) {
                            speedComboBoxSelection.value = value ?? 0;
                          },
                          style: const TextStyle(color: Colors.white),
                          underline: Container(), //empty line
                          dropdownColor: Colors.grey.shade800,
                          focusColor: Colors.black,
                          iconEnabledColor: Colors.white,
                          icon: const Icon(Icons.arrow_drop_down),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(onPressed: () {}, child: const Text("Freeze"))
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(child: MeasurementTableWidget()),
        ],
      ),
    );
  }
}
