import 'package:flutter/material.dart';
import 'package:keysight_gui/tab_widget.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class MeasurementWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final speedComboBoxSelection = useState(0);

    return Container(
      child: Padding(
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
                    Text(
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
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.57),
                                blurRadius: 5,
                              )
                            ]),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: DropdownButton(
                            value: speedComboBoxSelection.value,
                            items: [
                              DropdownMenuItem(
                                  child: Text("1 Second"), value: 0),
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
                            style: TextStyle(color: Colors.white),
                            underline: Container(), //empty line
                            dropdownColor: Colors.grey.shade800,
                            focusColor: Colors.black,
                            iconEnabledColor: Colors.white,
                            icon: Icon(Icons.arrow_drop_down),
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(onPressed: () {}, child: Text("Freeze"))
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 12,
            ),
            Expanded(
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
          ],
        ),
      ),
    );
  }
}
